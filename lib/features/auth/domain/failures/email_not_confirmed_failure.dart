import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';

/// Failure raised when a user tries to sign in before confirming their email.
class EmailNotConfirmedFailure extends Failure {
  /// Creates an [EmailNotConfirmedFailure].
  const EmailNotConfirmedFailure()
    : super(AuthFailureMessages.emailNotConfirmed);
}
