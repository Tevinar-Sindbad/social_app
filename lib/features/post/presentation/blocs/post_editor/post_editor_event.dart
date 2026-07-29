part of 'post_editor_bloc.dart';

@immutable
/// Represents post editor event.
sealed class PostEditorEvent {}

/// An add post.
final class AddPost extends PostEditorEvent {
  /// Creates a [AddPost].
  AddPost({
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

  /// The title.
  final String title;

  /// The content.
  final String content;

  /// The image.
  final File image;

  /// The topics.
  final List<PostTopic> topics;
}
