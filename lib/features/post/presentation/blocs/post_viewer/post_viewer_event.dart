part of 'post_viewer_bloc.dart';

/// The events of the [PostViewerBloc].
sealed class PostViewerEvent {
  const PostViewerEvent();
}

/// An event to load a post by its ID.
class LoadPost extends PostViewerEvent {
  /// Creates a [LoadPost] event.
  LoadPost({required this.postId});

  /// The stable post ID to load.
  ///
  /// The viewer is keyed by this primitive identifier so it can be restored
  /// from deep links and push notifications instead of depending on a
  /// previously passed post object.
  final String postId;
}

final class _PostReceived extends PostViewerEvent {
  const _PostReceived(this.result);

  final Either<Failure, Post> result;
}
