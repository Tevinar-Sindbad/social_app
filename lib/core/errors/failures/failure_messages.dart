// User-facing failure messages shared across features when the message is not
// owned by one specific business capability.

/// Common messages reused across multiple features.
abstract final class CommonFailureMessages {
  /// Message used when a list-size limit is invalid.
  static const invalidLimit = 'Limit must be greater than zero';

  /// Message used when the submitted request data is invalid in a generic way.
  static const invalidRequest =
      'The submitted data is invalid. Please review and try again.';

  /// Message used when a pagination cursor is invalid or expired.
  static const invalidCursor =
      'Unable to load more items. Please refresh and try again.';

  /// Message used for generic request conflicts that do not have a more
  /// specific client-owned message.
  static const conflict =
      'This request conflicts with existing data. Please try again.';
}
