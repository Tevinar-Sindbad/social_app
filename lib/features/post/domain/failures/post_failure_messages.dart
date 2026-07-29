/// Post-specific user-facing failure messages.
abstract final class PostFailureMessages {
  /// Message used when no image was provided.
  static const imageRequired = 'Image cannot be empty';

  /// Message used when the title is empty.
  static const titleRequired = 'Title cannot be empty';

  /// Message used when the content is empty.
  static const contentRequired = 'Content cannot be empty';

  /// Message used when no topic is selected.
  static const topicSelectionRequired = 'At least one topic must be selected';

  /// Message used when a requested post slice cursor is invalid.
  static const invalidCursor =
      'The requested post page is invalid. Please refresh and try again.';

  /// Message used when a post cannot be found anymore.
  static const notFound = 'Requested post not found.';
}
