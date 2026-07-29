part of 'auth_bloc.dart';

@immutable
/// Represents auth event.
abstract class AuthEvent {}

/// User intent: sign up
final class AuthSignup extends AuthEvent {
  /// Creates a [AuthSignup].
  AuthSignup({required this.email, required this.password});

  /// The email.
  final String email;

  /// The password.
  final String password;
}

/// User intent: sign in
final class AuthSignIn extends AuthEvent {
  /// Creates a [AuthSignIn].
  AuthSignIn({required this.email, required this.password});

  /// The email.
  final String email;

  /// The password.
  final String password;
}

/// User intent: resend the sign-up email confirmation message.
final class AuthResendSignUpConfirmationEmail extends AuthEvent {
  /// Creates a [AuthResendSignUpConfirmationEmail].
  AuthResendSignUpConfirmationEmail({required this.email});

  /// The email that should receive the confirmation email again.
  final String email;
}

/// Internal event emitted when a callback-related auth flow failure occurs.
final class AuthFlowFailureReceived extends AuthEvent {
  /// Creates an [AuthFlowFailureReceived].
  AuthFlowFailureReceived({required this.failure});

  /// User-safe auth flow failure emitted outside direct user actions.
  final Failure failure;
}
