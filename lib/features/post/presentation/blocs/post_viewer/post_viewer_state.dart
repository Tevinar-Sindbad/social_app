part of 'post_viewer_bloc.dart';

/// The states of the [PostViewerBloc].
sealed class PostViewerState {
  const PostViewerState();
}

/// The initial state of the [PostViewerBloc] before any action is taken.
final class PostViewerInitial extends PostViewerState {}

/// The loading state of the [PostViewerBloc] while a post is being fetched.
final class PostViewerLoading extends PostViewerState {}

/// The success state of the [PostViewerBloc] when a post is successfully
/// loaded.
final class PostViewerSuccess extends PostViewerState {
  /// Creates a [PostViewerSuccess] state with the loaded [post] and optional
  /// locally cached image file.
  PostViewerSuccess({
    required this.post,
    required this.imageFile,
  });

  /// The loaded post that can be displayed in the UI.
  final Post post;

  /// The locally cached or downloaded image file for [post], when available.
  final File? imageFile;
}

/// The failure state of the [PostViewerBloc] when an error occurs.
final class PostViewerFailure extends PostViewerState {
  /// Creates a [PostViewerFailure] state with the given error message.
  PostViewerFailure({required this.error});

  /// The error message describing the failure.
  final String error;
}
