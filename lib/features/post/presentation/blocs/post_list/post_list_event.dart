part of 'post_list_bloc.dart';

/// Base class for all events handled by [PostListBloc].
@immutable
sealed class PostListEvent {
  /// Creates a [PostListEvent].
  const PostListEvent();
}

/// Requests the initial list slice.
final class LoadInitialList extends PostListEvent {
  /// Creates a [LoadInitialList].
  const LoadInitialList();
}

/// Requests the next list slice using the current cursor.
final class LoadMoreList extends PostListEvent {
  /// Creates a [LoadMoreList].
  const LoadMoreList();
}

/// Requests a refresh of the first list slice.
final class RefreshList extends PostListEvent {
  /// Creates a [RefreshList].
  const RefreshList();
}

/// Prepends a newly created post to the top of the currently visible list.
final class PrependCreatedPost extends PostListEvent {
  /// Creates a [PrependCreatedPost].
  const PrependCreatedPost(this.post);

  /// Post created successfully by the backend.
  final Post post;
}

final class _InitialListSliceReceived extends PostListEvent {
  const _InitialListSliceReceived(this.result);

  final Either<Failure, PostListSlice> result;
}
