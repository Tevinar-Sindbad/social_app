import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/read_models/post_list_slice.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// Domain repository contract for post creation, reading, and list slices.
abstract interface class PostRepository {
  /// Creates a new post and returns the persisted domain entity.
  Future<Either<Failure, Post>> createPost({
    required File image,
    required String title,
    required String content,
    required List<PostTopic> topics,
  });

  /// Observes a cache-first snapshot of the initial post list slice and then
  /// refreshes that same slice once from the remote source.
  Stream<Either<Failure, PostListSlice>> observeInitialPostListSlice({
    required int limit,
  });

  /// Loads one cursor-based post list slice from the remote source.
  Future<Either<Failure, PostListSlice>> getPostListSlice({
    required int limit,
    String? cursor,
  });

  /// Observes a cache-first snapshot of the post and then refreshes that same
  /// post once from the remote source.
  ///
  /// The viewer route stays keyed by [postId] instead of receiving a full
  /// [Post] object so it can also be opened from deep links and push
  /// notifications, where only the identifier is reliably available. This
  /// cache-first observation restores the same fast-first-render behavior that
  /// passing a full post object would provide without weakening the route
  /// contract.
  Stream<Either<Failure, Post>> observePostById(String postId);

  /// Retrieves the locally cached or downloaded image file for [post].
  Future<Either<Failure, File?>> getPostImage(Post post);

  /// Clears locally cached post data for the current app session.
  Future<Either<Failure, void>> clearLocalCache();
}
