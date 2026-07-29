import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/post/data/models/post_list_slice_model.dart';
import 'package:social_app/features/post/data/models/post_model.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// A post local data source.
abstract interface class PostLocalDataSource {
  /// Upserts a list of posts into the local data source.
  Future<void> upsertPosts(List<PostModel> posts);

  /// Gets the first slice of the post list from the local data source.
  Future<PostListSliceModel> getFirstListSlice({required int limit});

  /// Gets a post by its ID from the local data source.
  ///
  /// This cached lookup lets the viewer screen render almost immediately using
  /// only a `postId`, which mirrors the UX of passing a full post object from
  /// the list screen while still supporting deep links and push notifications.
  Future<PostModel?> getPostById(String postId);

  /// Deletes a post from the local data source by its ID.
  Future<void> deletePost(String postId);

  /// Clears all posts from the local data source.
  Future<void> clearAll();
}

/// A post local data source implementation using Drift.
class PostLocalDataSourceDriftImpl implements PostLocalDataSource {
  /// Creates an instance of [PostLocalDataSourceDriftImpl].
  PostLocalDataSourceDriftImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<void> upsertPosts(List<PostModel> posts) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.cachedPosts,
        posts
            .map(
              (post) => CachedPostsCompanion.insert(
                id: post.id,
                posterId: post.posterId,
                title: post.title,
                content: post.content,
                imageRedirectUrl: post.imageRedirectUrl,
                topicsJson: jsonEncode(
                  post.topics.map((topic) => topic.name).toList(),
                ),
                createdAt: post.createdAt,
                updatedAt: post.updatedAt,
                posterName: post.posterName,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<PostListSliceModel> getFirstListSlice({
    required int limit,
  }) async {
    final cachedPosts =
        await (_database.select(_database.cachedPosts)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.createdAt,
                  mode: OrderingMode.desc,
                ),
                (table) => OrderingTerm(
                  expression: table.id,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    final items = cachedPosts.map(_toPostModel).toList();

    return PostListSliceModel(
      items: items,
      nextCursor: null,
    );
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    final query = _database.select(_database.cachedPosts)
      ..where((table) => table.id.equals(postId));

    final cachedPost = await query.getSingleOrNull();

    if (cachedPost == null) {
      return null;
    }

    return _toPostModel(cachedPost);
  }

  @override
  Future<void> deletePost(String postId) async {
    final deleteStatement = _database.delete(_database.cachedPosts)
      ..where((table) => table.id.equals(postId));
    await deleteStatement.go();
  }

  @override
  Future<void> clearAll() async {
    await _database.delete(_database.cachedPosts).go();
  }

  PostModel _toPostModel(CachedPost cachedPost) {
    return PostModel(
      id: cachedPost.id,
      posterId: cachedPost.posterId,
      posterName: cachedPost.posterName,
      title: cachedPost.title,
      content: cachedPost.content,
      imageRedirectUrl: cachedPost.imageRedirectUrl,
      topics: List<String>.from(
        jsonDecode(cachedPost.topicsJson) as List<dynamic>,
      ).map(PostTopic.fromValue).toList(),
      createdAt: cachedPost.createdAt,
      updatedAt: cachedPost.updatedAt,
    );
  }
}
