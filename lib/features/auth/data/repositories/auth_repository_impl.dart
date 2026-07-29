import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/config/env_variables.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/logging/app_talker_logger.dart';
import 'package:social_app/features/auth/domain/entities/auth_identity.dart';
import 'package:social_app/features/auth/domain/events/auth_session_change.dart';
import 'package:social_app/features/auth/domain/failures/auth_failures_mapper.dart';
import 'package:social_app/features/auth/domain/failures/email_confirmation_link_expired_failure.dart';
import 'package:social_app/features/auth/domain/failures/pkce_flow_state_expired_failure.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete [AuthRepository] backed directly by Supabase Auth.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates a [AuthRepositoryImpl].
  const AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AppTalkerLogger logger,
  }) : _supabaseClient = supabaseClient,
       _logger = logger;

  final SupabaseClient _supabaseClient;
  final AppTalkerLogger _logger;

  /// Broadcasts auth-flow-only failures that should stay in auth UI instead of
  /// being interpreted as global session-state failures.
  static final StreamController<Failure> _authFlowFailuresController =
      StreamController<Failure>.broadcast();

  @override
  Future<Either<Failure, void>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return right(null);
    } on Exception catch (error, stackTrace) {
      // An exception will be thrown if the email is still not confirmed
      final failure = mapAuthExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in AuthRepositoryImpl.signInWithEmailPassword.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: EnvVariables.supabaseEmailRedirectUrl,
      );

      return right(null);
    } on Exception catch (error, stackTrace) {
      final failure = mapAuthExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in AuthRepositoryImpl.signUpWithEmailPassword.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return right(null);
    } on Exception catch (error, stackTrace) {
      final failure = mapAuthExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in AuthRepositoryImpl.signOut.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> resendSignUpConfirmationEmail({
    required String email,
  }) async {
    try {
      await _supabaseClient.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: EnvVariables.supabaseEmailRedirectUrl,
      );

      return right(null);
    } on Exception catch (error, stackTrace) {
      final failure = mapAuthExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'AuthRepositoryImpl.resendSignUpConfirmationEmail.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, AuthSessionChange>> authStateChanges() {
    late final StreamController<Either<Failure, AuthSessionChange>> controller;
    late final StreamSubscription<AuthState> subscription;

    controller = StreamController<Either<Failure, AuthSessionChange>>(
      onListen: () {
        subscription = _supabaseClient.auth.onAuthStateChange.listen(
          (authState) {
            final authSessionChange = _mapAuthStateChange(authState);
            if (authSessionChange == null) {
              return;
            }

            controller.add(authSessionChange);
          },
          onError: (Object error, StackTrace stackTrace) {
            final recoveredChange =
                recoverSignedInFromExpiredConfirmationLinkError(
                  error: error,
                  currentSession: _supabaseClient.auth.currentSession,
                );
            if (recoveredChange != null) {
              controller.add(
                right<Failure, AuthSessionChange>(recoveredChange),
              );
              return;
            }

            final failure = mapAuthExceptionToFailure(error);

            if (failure is EmailConfirmationLinkExpiredFailure ||
                failure is PkceFlowStateExpiredFailure) {
              _authFlowFailuresController.add(failure);
              return;
            }

            if (failure is UnexpectedFailure) {
              _logger.error(
                'Unexpected error in AuthRepositoryImpl.authStateChanges.',
                error: error,
                stackTrace: stackTrace,
              );
            }

            controller.add(left<Failure, AuthSessionChange>(failure));
          },
        );
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }

  @override
  Stream<Failure> authFlowFailures() {
    return _authFlowFailuresController.stream;
  }

  /// Recovers a signed-in session when a stale confirmation link is opened
  /// after Supabase already established the local session successfully.
  static AuthSessionChange? recoverSignedInFromExpiredConfirmationLinkError({
    required Object error,
    required Session? currentSession,
  }) {
    final failure = mapAuthExceptionToFailure(error);
    if (failure is! EmailConfirmationLinkExpiredFailure) {
      return null;
    }

    final identity = _extractAuthIdentityFromSession(currentSession);
    if (identity == null) {
      return null;
    }

    return SignedIn(identity);
  }

  Either<Failure, AuthSessionChange>? _mapAuthStateChange(AuthState authState) {
    switch (authState.event) {
      case AuthChangeEvent.initialSession:
        return _mapInitialSessionChange(authState.session);
      case AuthChangeEvent.signedIn:
        return _mapSignedInChange(authState.session);
      case AuthChangeEvent.signedOut:
        return right<Failure, AuthSessionChange>(const SignedOut());
      case _:
        return null;
    }
  }

  Either<Failure, AuthSessionChange> _mapInitialSessionChange(
    Session? session,
  ) {
    return right<Failure, AuthSessionChange>(
      InitialSession(_extractAuthIdentityFromSession(session)),
    );
  }

  Either<Failure, AuthSessionChange> _mapSignedInChange(Session? session) {
    final identity = _extractAuthIdentityFromSession(session);
    if (identity == null) {
      return left<Failure, AuthSessionChange>(const UnexpectedFailure());
    }

    return right<Failure, AuthSessionChange>(SignedIn(identity));
  }

  static AuthIdentity? _extractAuthIdentityFromSession(Session? session) {
    final email = session?.user.email;
    if (session == null || email == null || email.isEmpty) {
      return null;
    }

    return AuthIdentity(id: session.user.id, email: email);
  }
}
