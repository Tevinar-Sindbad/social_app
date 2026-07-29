/// Base type for recoverable application failures exposed beyond the data
/// layer.
///
/// A [Failure] is the user-safe representation of an error condition after low-
/// level exceptions have been mapped into something the rest of the app can
/// reason about. Use [message] for UI copy that can be shown directly to the
/// user.
abstract class Failure {
  /// Creates a [Failure] with a safe display [message].
  const Failure(this.message);

  /// Safe, user-facing copy that may be rendered directly in the UI.
  final String message;
}

/// Failure raised when the app cannot complete a request because the backend
/// could not be reached reliably.
///
/// This covers transport-level problems such as timeouts, offline states, DNS
/// failures, and connection errors. It should not be used for valid HTTP
/// responses that contain an application error payload.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure()
    : super('Unable to reach the server. Check your connection and try again.');
}

/// Failure raised when the current authentication state is missing, expired, or
/// otherwise no longer accepted by the backend.
///
/// This typically means the user must authenticate again before retrying the
/// action.
class UnauthorizedFailure extends Failure {
  /// Creates a [UnauthorizedFailure].
  const UnauthorizedFailure()
    : super('Your session has expired. Please sign in again.');
}

/// Failure raised when the user is authenticated but does not have permission
/// to perform the requested action.
class ForbiddenFailure extends Failure {
  /// Creates a [ForbiddenFailure].
  const ForbiddenFailure()
    : super('You do not have permission to perform this action.');
}

/// Failure raised when user input or request parameters do not satisfy business
/// or transport validation rules.
///
/// The [message] is expected to be specific enough to help the user correct the
/// invalid input.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message);
}

/// Failure raised when the requested resource does not exist or is no longer
/// accessible by identifier.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure([
    super.message = 'Requested resource not found.',
  ]);
}

/// Failure raised when an operation fails in a way the app does not classify
/// more specifically.
///
/// This is the broad fallback for unrecognized backend responses, unexpected
/// local exceptions, or any condition that should not leak internal details to
/// the user.
class UnexpectedFailure extends Failure {
  /// Creates a [UnexpectedFailure].
  const UnexpectedFailure() : super('Something went wrong. Please try again.');
}
