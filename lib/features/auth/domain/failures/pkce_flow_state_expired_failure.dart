import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';

/// Failure raised when email confirmation succeeds but the app can no longer
/// exchange the callback into a local auth session because the Proof Key for
/// Code Exchange has failed or expired
class PkceFlowStateExpiredFailure extends Failure {
  /// Creates a [PkceFlowStateExpiredFailure].
  const PkceFlowStateExpiredFailure()
    : super(AuthFailureMessages.confirmationSessionExpired);
}
