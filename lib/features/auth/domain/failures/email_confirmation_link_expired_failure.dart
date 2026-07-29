import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';

/// Failure raised when a confirmation link can no longer establish a session.
class EmailConfirmationLinkExpiredFailure extends Failure {
  /// Creates an [EmailConfirmationLinkExpiredFailure].
  const EmailConfirmationLinkExpiredFailure()
    : super(AuthFailureMessages.emailConfirmationLinkExpired);
}
