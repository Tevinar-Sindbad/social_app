/// Chat-specific user-facing failure messages.
abstract final class ChatFailureMessages {
  /// Message used when no chat member is selected.
  static const memberSelectionRequired =
      'At least one chat member must be selected';

  /// Message used when the first message content is empty.
  static const firstMessageContentRequired =
      'First message content cannot be empty';

  /// Message used when a regular chat message content is empty.
  static const messageContentRequired = 'Message content cannot be empty';

  /// Message used when the submitted members are invalid.
  static const invalidMembers = 'Please select valid chat members.';

  /// Message used when the submitted message content is invalid.
  static const invalidMessageContent = 'Please enter a valid message.';
}
