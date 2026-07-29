import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:social_app/app/session/signed_in_app_user.dart';
import 'package:social_app/app/use_cases/clear_session_data_use_case.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/entities/auth_identity.dart';
import 'package:social_app/features/auth/domain/events/auth_session_change.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_out_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_state_changes_use_case.dart';
import 'package:social_app/features/profile/domain/results/current_profile_result.dart';
import 'package:social_app/features/profile/domain/usecases/clear_cached_current_profile_use_case.dart';
import 'package:social_app/features/profile/domain/usecases/resolve_current_profile_use_case.dart';

part 'app_user_state.dart';

/// App-level cubit that exposes the **current authentication session**
/// to the entire application.
///
/// Responsibilities:
/// - listen to `WatchAuthStateChanges`
/// - expose global auth-routing state
/// - provide a global `signOut()` intent
///
/// This cubit does NOT handle authentication flows (sign-in / sign-up).
/// It owns only the app-wide state that other features and the router depend
/// on.
class AppUserCubit extends Cubit<AppUserState> {
  /// Creates a [AppUserCubit].
  AppUserCubit({
    required ClearCachedCurrentProfileUseCase clearCachedCurrentProfileUseCase,
    required ClearSessionDataUseCase clearSessionDataUseCase,
    required ResolveCurrentProfileUseCase resolveCurrentProfileUseCase,
    required UserSignOutUseCase userSignOut,
    required WatchAuthStateChanges watchAuthStateChanges,
  }) : _clearCachedCurrentProfileUseCase = clearCachedCurrentProfileUseCase,
       _clearSessionDataUseCase = clearSessionDataUseCase,
       _resolveCurrentProfileUseCase = resolveCurrentProfileUseCase,
       _userSignOut = userSignOut,
       _watchAuthStateChanges = watchAuthStateChanges,
       super(AppUserLoading()) {
    _subscribeToAuthStateChanges();
  }

  final ClearCachedCurrentProfileUseCase _clearCachedCurrentProfileUseCase;
  final ClearSessionDataUseCase _clearSessionDataUseCase;
  final ResolveCurrentProfileUseCase _resolveCurrentProfileUseCase;
  final UserSignOutUseCase _userSignOut;
  late final StreamSubscription<Either<Failure, AuthSessionChange>>
  _authStateChangesSub;
  final WatchAuthStateChanges _watchAuthStateChanges;

  /// Monotonic token used to invalidate older async auth resolutions.
  ///
  /// Auth stream events can arrive while a previous profile-resolution future
  /// is still in flight. By tagging each async resolution attempt with the
  /// latest id, the cubit can ignore stale completions and avoid emitting state
  /// from outdated auth events.
  int _authResolutionId = 0;

  /// Returns the currently signed-in user, or `null` when signed out.
  SignedInAppUser? get currentUser {
    final currentState = state;

    if (currentState is AppUserSignedIn) {
      return currentState.user;
    }

    return null;
  }

  @override
  Future<void> close() async {
    try {
      await _authStateChangesSub.cancel();
    } finally {
      await super.close();
    }
  }

  /// Subscribes to auth-state changes and keeps session cleanup aligned with
  /// sign-out and user-switch transitions.
  void _subscribeToAuthStateChanges() {
    _authStateChangesSub = _watchAuthStateChanges().listen((event) async {
      await event.fold(
        (failure) {
          _invalidateAuthResolutions();
          emit(AppUserFailure(failure.message));
        },
        _handleAuthSessionChange,
      );
    });
  }

  /// Global sign-out intent
  Future<void> signOut() async {
    _invalidateAuthResolutions();
    emit(AppUserLoading());

    final result = await _userSignOut();
    await result.fold(
      (failure) async {
        if (!isClosed) {
          emit(AppUserFailure(failure.message));
        }
      },
      (_) => _emitSignedOut(),
    );
  }

  /// Marks the app as waiting for email confirmation before any real session
  /// can exist.
  void awaitEmailConfirmation({required String email}) {
    if (!isClosed) {
      emit(AppUserAwaitingEmailConfirmation(email: email));
    }
  }

  /// Leaves the pending email-confirmation flow and returns the app to the
  /// signed-out auth routes.
  Future<void> cancelAwaitingEmailConfirmation() async {
    if (state is! AppUserAwaitingEmailConfirmation) {
      return;
    }

    _invalidateAuthResolutions();
    await _emitSignedOut();
  }

  /// Re-resolves the current authenticated identity into an app user.
  ///
  /// This is used after onboarding creates the first profile row while the
  /// Supabase session itself stays unchanged.
  ///
  /// The auth identity is read from [AppUserNeedsOnboarding] instead of a
  /// private cubit field so all session-relevant state stays inside the
  /// emitted state tree.
  Future<void> refreshCurrentUser() async {
    final currentState = state;
    if (currentState is! AppUserNeedsOnboarding) {
      return;
    }

    if (!isClosed) {
      emit(AppUserLoading());
    }

    await _resolveAppUserFromIdentity(currentState.identity);
  }

  Future<void> _handleAuthSessionChange(AuthSessionChange change) async {
    switch (change) {
      case InitialSession(:final identity):
        if (identity == null) {
          if (state is AppUserAwaitingEmailConfirmation) {
            return;
          }

          // On app bootstrap, if initial session has a null identity, then
          // clear all current user data and emit SignedOut state
          _invalidateAuthResolutions();
          await _emitSignedOut();
          return;
        }

        await _resolveAppUserFromIdentity(identity);

      case SignedIn(:final identity):
        await _resolveAppUserFromIdentity(identity);

      case SignedOut():
        if (state is AppUserAwaitingEmailConfirmation) {
          return;
        }

        _invalidateAuthResolutions();
        await _emitSignedOut();
    }
  }

  /// Finalizes the signed-out state after best-effort cleanup of session data.
  Future<void> _emitSignedOut() async {
    if (state is AppUserSignedOut) {
      return;
    }

    await _clearSentryUser();
    await _clearCachedCurrentProfileUseCase();
    await _clearSessionDataUseCase();

    if (!isClosed && state is! AppUserSignedOut) {
      emit(AppUserSignedOut());
    }
  }

  /// Resolves the authenticated identity into either a signed-in app user or
  /// an onboarding-required state.
  Future<void> _resolveAppUserFromIdentity(AuthIdentity identity) async {
    final resolutionId = _nextAuthResolutionId();
    final result = await _resolveCurrentProfileUseCase();

    // If the auth-resolution attempt is an old one, cancel the function
    // resolution because it's no longer relevant
    if (_isStaleResolution(resolutionId)) {
      return;
    }

    await result.fold(
      (failure) {
        emit(AppUserFailure(failure.message));
      },
      (currentProfile) async {
        switch (currentProfile) {
          case CurrentProfile(:final profile):
            final user = SignedInAppUser(
              id: profile.id,
              name: profile.name,
              email: identity.email,
            );

            await _setSentryUser(user);

            if (!_isStaleResolution(resolutionId)) {
              emit(AppUserSignedIn(user));
            }

          case CurrentProfileMissing():
            emit(AppUserNeedsOnboarding(identity));
        }
      },
    );
  }

  /// Allocates the next auth-resolution token for a fresh async attempt.
  int _nextAuthResolutionId() {
    return ++_authResolutionId;
  }

  /// Invalidates every in-flight auth resolution started before this call.
  void _invalidateAuthResolutions() {
    _authResolutionId += 1;
  }

  /// Returns whether an async auth resolution is outdated or unusable.
  bool _isStaleResolution(int resolutionId) {
    return resolutionId != _authResolutionId || isClosed;
  }

  /// Mirrors the signed-in app user into Sentry's per-request user context.
  Future<void> _setSentryUser(SignedInAppUser user) async {
    await Sentry.configureScope((scope) async {
      await scope.setUser(
        SentryUser(id: user.id),
      );
    });
  }

  /// Clears any previously configured Sentry user context.
  Future<void> _clearSentryUser() async {
    await Sentry.configureScope((scope) async {
      await scope.setUser(null);
    });
  }
}
