part of 'auth_bloc.dart';

@immutable
/// Represents auth state.
abstract class AuthState {
  /// Creates a [AuthState].
  const AuthState();
}

/// Idle auth state when no auth request is currently running.
final class AuthIdle extends AuthState {}

/// An auth loading.
final class AuthLoading extends AuthState {}

/// State telling the user to confirm their email before continuing.
final class AuthAwaitingEmailConfirmation extends AuthState {
  /// Creates a [AuthAwaitingEmailConfirmation].
  const AuthAwaitingEmailConfirmation({
    required this.email,
  });

  /// Email address that received the confirmation email.
  final String email;
}

/// Resend state confirming that the email confirmation message was sent again.
final class AuthConfirmationEmailResent extends AuthState {
  /// Creates a [AuthConfirmationEmailResent].
  const AuthConfirmationEmailResent({
    required this.email,
  });

  /// Email address that received the confirmation email again.
  final String email;
}

/// State telling the user that the current device can no longer complete the
/// email-confirmation callback and that another action is now required.
final class AuthConfirmationActionRequired extends AuthState {
  /// Creates an [AuthConfirmationActionRequired].
  const AuthConfirmationActionRequired({
    required this.message,
  });

  /// User-facing explanation of why the user must sign in or resend.
  final String message;
}

/// Represents auth failure.
final class AuthFailure extends AuthState {
  /// Creates a [AuthFailure].
  const AuthFailure(this.message);

  /// The message.
  final String message;
}
