import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';
import 'package:social_app/features/auth/domain/failures/email_confirmation_link_expired_failure.dart';
import 'package:social_app/features/auth/domain/failures/email_not_confirmed_failure.dart';
import 'package:social_app/features/auth/domain/failures/invalid_credentials_failure.dart';
import 'package:social_app/features/auth/domain/failures/pkce_flow_state_expired_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps auth-owned exceptions and backend error codes into [Failure]s.
Failure mapAuthExceptionToFailure(Object error) {
  if (error is AuthWeakPasswordException) {
    return const ValidationFailure(AuthFailureMessages.invalidPassword);
  }

  if (error is AuthApiException) {
    switch (error.code) {
      case 'email_exists':
      case 'user_already_exists':
      case 'email_address_not_authorized':
        return const ValidationFailure(AuthFailureMessages.emailAlreadyInUse);

      case 'email_not_confirmed':
        return const EmailNotConfirmedFailure();

      case 'invalid_credentials':
      case 'invalid_grant':
        return const InvalidCredentialsFailure();

      case 'flow_state_expired':
      case 'flow_state_not_found':
        return const PkceFlowStateExpiredFailure();
    }

    if (_isExpiredEmailConfirmationLink(error)) {
      return const EmailConfirmationLinkExpiredFailure();
    }

    return const UnexpectedFailure();
  }

  if (error is AuthException && _isExpiredEmailConfirmationLink(error)) {
    return const EmailConfirmationLinkExpiredFailure();
  }

  return const UnexpectedFailure();
}

bool _isExpiredEmailConfirmationLink(AuthException error) {
  final normalizedMessage = error.message.toLowerCase();

  return error.statusCode == 'otp_expired' ||
      error.code == 'otp_expired' ||
      error.code == 'access_denied' ||
      normalizedMessage.contains('email link is invalid or has expired') ||
      normalizedMessage.contains('token has expired or is invalid');
}
