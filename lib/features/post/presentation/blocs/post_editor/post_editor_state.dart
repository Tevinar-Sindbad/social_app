part of 'post_editor_bloc.dart';

/// Base state emitted by [PostEditorBloc].
@immutable
sealed class PostEditorState {
  /// Creates a [PostEditorState].
  const PostEditorState();
}

/// Initial idle state before any upload attempt starts.
final class PostInitial extends PostEditorState {
  /// Creates a [PostInitial].
  const PostInitial();
}

/// State emitted while a post upload request is in progress.
final class PostLoading extends PostEditorState {
  /// Creates a [PostLoading].
  const PostLoading();
}

/// State emitted after a post is uploaded successfully.
final class PostUploadSuccess extends PostEditorState {
  /// Creates a [PostUploadSuccess].
  const PostUploadSuccess(this.post);

  /// Uploaded post returned by the backend.
  final Post post;
}

/// State emitted when the upload request fails.
final class PostFailure extends PostEditorState {
  /// Creates a [PostFailure].
  const PostFailure(this.error);

  /// Human-readable error message.
  final String error;
}
