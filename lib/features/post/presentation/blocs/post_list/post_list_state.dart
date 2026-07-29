part of 'post_list_bloc.dart';

/// Base state for the post list screen.
@immutable
sealed class PostListState {
  /// Creates a [PostListState].
  const PostListState({
    required this.posts,
    required this.nextCursor,
    required this.isFromCache,
    required this.refreshError,
  });

  /// Posts currently rendered in the list.
  final List<Post> posts;

  /// Remote cursor used to request the next list slice, when available.
  final String? nextCursor;

  /// Whether the latest emitted slice came from the local cache.
  final bool isFromCache;

  /// Refresh error kept alongside still-usable content, when applicable.
  final String? refreshError;
}

/// List state emitted while the screen is still loading content.
final class PostListLoading extends PostListState {
  /// Creates a [PostListLoading].
  const PostListLoading({
    required super.posts,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// List state emitted when at least one list slice has been loaded.
final class PostListSuccess extends PostListState {
  /// Creates a [PostListSuccess].
  const PostListSuccess({
    required super.posts,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// List state emitted when loading fails and no usable content is available.
final class PostListFailure extends PostListState {
  /// Creates a [PostListFailure].
  const PostListFailure({
    required this.error,
    required super.posts,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });

  /// Error shown to the user when the list could not be loaded.
  final String error;
}
