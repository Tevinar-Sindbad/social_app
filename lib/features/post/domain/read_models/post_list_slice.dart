import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/post/domain/entities/post.dart';

/// Cache-first snapshot of one post list slice.
class PostListSlice {
  /// Creates a [PostListSlice].
  const PostListSlice({
    required this.posts,
    required this.source,
    required this.nextCursor,
    this.refreshFailure,
  });

  /// Posts currently available for the requested list slice.
  final List<Post> posts;

  /// Origin of the currently emitted list slice.
  final PostListSource source;

  /// Opaque remote cursor used to request the next list slice, when available.
  final String? nextCursor;

  /// Remote refresh failure when cached content is still available.
  final Failure? refreshFailure;
}

/// Origin of a [PostListSlice].
enum PostListSource {
  /// List slice emitted from the local cache.
  cache,

  /// List slice emitted from the remote backend.
  remote,
}
