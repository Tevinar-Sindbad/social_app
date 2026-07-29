import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';

/// Failure raised when submitted sign-in credentials are rejected.
class InvalidCredentialsFailure extends Failure {
  /// Creates an [InvalidCredentialsFailure].
  const InvalidCredentialsFailure()
    : super(AuthFailureMessages.invalidCredentials);
}
