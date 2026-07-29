/// Backend error payload normalized from the public HTTP error contract.
///
/// This exception is reserved for non-success backend responses that match the
/// standardized JSON shape produced by the backend exception filter. Every
/// field is required because a [RemoteServerException] now means "validated
/// backend error payload", not just "some remote failure happened".
class RemoteServerException implements Exception {
  /// Creates a [RemoteServerException].
  const RemoteServerException({
    required this.message,
    required this.code,
    required this.statusCode,
    required this.path,
    required this.timestamp,
  });

  /// Human-readable backend error message.
  final String message;

  /// Stable backend error code used for client-side failure mapping.
  final String code;

  /// HTTP status code returned by the backend.
  final int statusCode;

  /// Request path reported by the backend when the error was generated.
  final String path;

  /// Backend timestamp describing when the error response was created.
  final DateTime timestamp;

  @override
  String toString() {
    return 'RemoteServerException: $message '
        '(code: $code, statusCode: $statusCode, path: $path, '
        'timestamp: $timestamp)';
  }
}

/// Malformed or incomplete backend response on a path that was expected to
/// succeed.
///
/// This is used when the app reaches the backend successfully but the returned
/// payload does not satisfy the contract required by the client, for example a
/// missing response body or a JSON shape that cannot be parsed correctly.
class RemoteInvalidResponseException implements Exception {
  /// Creates an [RemoteInvalidResponseException].
  const RemoteInvalidResponseException({required this.message, this.code});

  /// Diagnostic description of the violated backend response contract.
  final String message;

  /// Optional internal code reserved for future classification needs.
  final String? code;

  @override
  String toString() => 'RemoteInvalidResponseException: $message (code: $code)';
}

/// Unclassified local exception raised by the client itself.
///
/// This is the broad fallback for failures that do not clearly belong to the
/// remote transport contract, input validation, or another specialized client
/// exception type.
class RemoteUnexpectedException implements Exception {
  /// Creates an [RemoteUnexpectedException].
  const RemoteUnexpectedException({required this.message, this.code});

  /// Diagnostic message describing the unexpected local failure.
  final String message;

  /// Optional internal code reserved for future classification needs.
  final String? code;

  @override
  String toString() => 'RemoteUnexpectedException: $message (code: $code)';
}

/// Transport-level connectivity failure while attempting to reach the backend.
///
/// This covers conditions such as timeouts, socket-level connection errors, or
/// other cases where no valid backend error payload could be obtained.
class RemoteNetworkException implements Exception {
  /// Creates a [RemoteNetworkException].
  const RemoteNetworkException({required this.message, this.code});

  /// Diagnostic description of the network failure.
  final String message;

  /// Optional internal code reserved for future classification needs.
  final String? code;

  @override
  String toString() => 'RemoteNetworkException: $message (code: $code)';
}

/// Local authentication or authorization precondition failure.
///
/// This exception is raised when the client already knows it cannot proceed
/// because required auth state is missing or invalid, without needing a fresh
/// backend error response to discover that fact.
class RemoteUnauthorizedException implements Exception {
  /// Creates an [RemoteUnauthorizedException].
  const RemoteUnauthorizedException({required this.message, this.code});

  /// Diagnostic description of the authorization precondition failure.
  final String message;

  /// Optional internal code reserved for future classification needs.
  final String? code;

  @override
  String toString() => 'RemoteUnauthorizedException: $message (code: $code)';
}
