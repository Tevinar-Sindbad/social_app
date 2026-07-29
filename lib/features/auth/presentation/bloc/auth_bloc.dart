import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';
import 'package:social_app/features/auth/domain/failures/email_confirmation_link_expired_failure.dart';
import 'package:social_app/features/auth/domain/failures/email_not_confirmed_failure.dart';
import 'package:social_app/features/auth/domain/failures/pkce_flow_state_expired_failure.dart';
import 'package:social_app/features/auth/domain/usecases/resend_sign_up_confirmation_email_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_up_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_flow_failures_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Feature BLoC responsible for **authentication flows**.
///
/// Responsibilities:
/// - handle user intents (sign up, sign in)
/// - execute auth use cases
///
/// This bloc owns **authentication logic**, but not global session state.
/// Global access to the current user is handled by `AppUserCubit`.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates a [AuthBloc].
  AuthBloc({
    required ResendSignUpConfirmationEmailUseCase
    resendSignUpConfirmationEmailUseCase,
    required UserSignUpUseCase userSignUpUseCase,
    required UserSignInUseCase userSignInUseCase,
    required WatchAuthFlowFailuresUseCase watchAuthFlowFailuresUseCase,
  }) : _resendSignUpConfirmationEmailUseCase =
           resendSignUpConfirmationEmailUseCase,
       _userSignUpUseCase = userSignUpUseCase,
       _userSignInUseCase = userSignInUseCase,
       super(AuthIdle()) {
    on<AuthResendSignUpConfirmationEmail>(_onAuthResendSignUpConfirmationEmail);
    on<AuthSignup>(_onAuthSignUp);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthFlowFailureReceived>(_onAuthFlowFailureReceived);

    _authFlowFailuresSub = watchAuthFlowFailuresUseCase().listen((failure) {
      if (!isClosed) {
        add(AuthFlowFailureReceived(failure: failure));
      }
    });
  }
  final ResendSignUpConfirmationEmailUseCase
  _resendSignUpConfirmationEmailUseCase;
  final UserSignUpUseCase _userSignUpUseCase;
  final UserSignInUseCase _userSignInUseCase;
  late final StreamSubscription<Failure> _authFlowFailuresSub;

  @override
  Future<void> close() async {
    await _authFlowFailuresSub.cancel();
    return super.close();
  }

  void _onAuthFlowFailureReceived(
    AuthFlowFailureReceived event,
    Emitter<AuthState> emit,
  ) {
    final failure = event.failure;

    if (failure is EmailConfirmationLinkExpiredFailure ||
        failure is PkceFlowStateExpiredFailure) {
      emit(
        const AuthConfirmationActionRequired(
          message: AuthFailureMessages.confirmationActionRequired,
        ),
      );
      return;
    }

    emit(AuthFailure(failure.message));
  }

  Future<void> _onAuthResendSignUpConfirmationEmail(
    AuthResendSignUpConfirmationEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _resendSignUpConfirmationEmailUseCase(
      event.email,
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(
        AuthConfirmationEmailResent(
          email: event.email,
        ),
      ),
    );
  }

  Future<void> _onAuthSignUp(AuthSignup event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUpUseCase(
      UserSignUpParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) =>
          // We want to emit this state because a succeded sign up won't trigger
          // any auth state changes from Supabase, therefore router won't have
          // any ower for redirection. So this state is emited so sign up page
          // can redirect to email confirmation pending page on sign up succeed.
          // Once the user will confirm its email, he will be redirected to the
          // app and Supabase will emit a signed in event, which the router
          // redirect will handle.
          emit(
            AuthAwaitingEmailConfirmation(
              email: event.email,
            ),
          ),
    );
  }

  Future<void> _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignInUseCase(
      UserSignInParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) {
        if (failure is EmailNotConfirmedFailure) {
          emit(
            AuthAwaitingEmailConfirmation(
              email: event.email,
            ),
          );
          return;
        }

        emit(AuthFailure(failure.message));
      },
      (_) => emit(AuthIdle()),
    );
  }
}
