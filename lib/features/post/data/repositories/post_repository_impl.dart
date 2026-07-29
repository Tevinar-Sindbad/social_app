import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/logging/app_talker_logger.dart';
import 'package:social_app/features/post/data/models/post_list_slice_model.dart';
import 'package:social_app/features/post/data/models/post_model.dart';
import 'package:social_app/features/post/data/sources/post_local_data_source.dart';
import 'package:social_app/features/post/data/sources/post_remote_data_source.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/failures/post_failures_mapper.dart';
import 'package:social_app/features/post/domain/read_models/post_list_slice.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// Repository implementation that composes post local and remote data sources
/// into cache-first domain operations.
class PostRepositoryImpl implements PostRepository {
  /// Creates a [PostRepositoryImpl].
  PostRepositoryImpl({
    required this.postRemoteDataSource,
    required this.postLocalDataSource,
    required this.imageFileCache,
    required AppTalkerLogger logger,
  }) : _logger = logger;

  /// Remote data source used for backend post operations.
  final PostRemoteDataSource postRemoteDataSource;

  /// Local data source used for caching the first list slice and individual
  /// post records.
  final PostLocalDataSource postLocalDataSource;

  /// Cache used to persist post images locally after download.
  final ImageFileCache imageFileCache;
  final AppTalkerLogger _logger;

  @override
  Future<Either<Failure, Post>> createPost({
    required File image,
    required String title,
    required String content,
    required List<PostTopic> topics,
  }) async {
    try {
      final post = await postRemoteDataSource.createPost(
        title: title,
        content: content,
        image: image,
        topics: topics.map((topic) => topic.name).toList(),
      );

      await postLocalDataSource.upsertPosts([post]);

      return right(post.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.createPost',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, PostListSlice>> observeInitialPostListSlice({
    required int limit,
  }) async* {
    PostListSliceModel? cachedSlice;

    try {
      cachedSlice = await postLocalDataSource.getFirstListSlice(
        limit: limit,
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'PostRepositoryImpl.observeInitialPostListSlice local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedSlice != null && cachedSlice.items.isNotEmpty) {
      yield right(
        PostListSlice(
          posts: cachedSlice.items.map((post) => post.toEntity()).toList(),
          source: PostListSource.cache,
          nextCursor: cachedSlice.nextCursor,
        ),
      );
    }

    try {
      final remoteSlice = await postRemoteDataSource.getPostListSlice(
        limit: limit,
      );

      await postLocalDataSource.upsertPosts(remoteSlice.items);

      yield right(
        PostListSlice(
          posts: remoteSlice.items.map((post) => post.toEntity()).toList(),
          source: PostListSource.remote,
          nextCursor: remoteSlice.nextCursor,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'PostRepositoryImpl.observeInitialPostListSlice remote fetch',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedSlice == null || cachedSlice.items.isEmpty) {
        yield left(failure);
      } else {
        yield right(
          PostListSlice(
            posts: cachedSlice.items.map((post) => post.toEntity()).toList(),
            source: PostListSource.cache,
            nextCursor: cachedSlice.nextCursor,
            refreshFailure: failure,
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, PostListSlice>> getPostListSlice({
    required int limit,
    String? cursor,
  }) async {
    try {
      final remoteSlice = await postRemoteDataSource.getPostListSlice(
        limit: limit,
        cursor: cursor,
      );

      await postLocalDataSource.upsertPosts(remoteSlice.items);

      return right(
        PostListSlice(
          posts: remoteSlice.items.map((post) => post.toEntity()).toList(),
          source: PostListSource.remote,
          nextCursor: remoteSlice.nextCursor,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.getPostListSlice',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, Post>> observePostById(String postId) async* {
    PostModel? cachedPost;

    try {
      cachedPost = await postLocalDataSource.getPostById(postId);
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.observePostById local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedPost != null) {
      yield right(cachedPost.toEntity());
    }

    try {
      final remotePost = await postRemoteDataSource.getPostById(postId);
      await postLocalDataSource.upsertPosts([remotePost]);
      yield right(remotePost.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.observePostById',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedPost == null) {
        yield left(failure);
      }
    }
  }

  @override
  Future<Either<Failure, File?>> getPostImage(Post post) async {
    try {
      final imageFile = await imageFileCache.getOrDownload(
        cacheKey: post.id,
        imageUrl: post.imageRedirectUrl,
      );

      return right(imageFile);
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.getPostImage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalCache() async {
    try {
      await postLocalDataSource.clearAll();
      return right(null);
    } on Exception catch (error, stackTrace) {
      final failure = mapPostExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in PostRepositoryImpl.clearLocalCache',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }
}
