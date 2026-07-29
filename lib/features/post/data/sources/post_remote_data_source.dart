import 'dart:io';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_mapper.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/post/data/models/post_list_slice_model.dart';
import 'package:social_app/features/post/data/models/post_model.dart';

/// Remote post data source backed by the HTTP API.
abstract interface class PostRemoteDataSource {
  /// Creates a new post remotely and returns the persisted payload.
  Future<PostModel> createPost({
    required String title,
    required String content,
    required File image,
    required List<String> topics,
  });

  /// Fetches one cursor-based slice of the remote post list.
  Future<PostListSliceModel> getPostListSlice({
    int limit = 20,
    String? cursor,
  });

  /// Fetches one post by its stable identifier.
  Future<PostModel> getPostById(String postId);
}

/// Default [PostRemoteDataSource] implementation using Dio.
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  /// Creates a [PostRemoteDataSourceImpl].
  const PostRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<PostModel> createPost({
    required String title,
    required String content,
    required File image,
    required List<String> topics,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/posts',
        data: FormData.fromMap({
          'title': title,
          'content': content,
          'topics': topics,
          'image': await MultipartFile.fromFile(
            image.path,
          ),
        }),
      );
      final body = JsonReader.asObject(
        response.data,
        'response',
        source: 'createPost response payload',
      );

      return PostModel.fromJson(body);
    });
  }

  @override
  Future<PostListSliceModel> getPostListSlice({
    int limit = 20,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts',
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );
      final body = JsonReader.asObject(
        response.data,
        'response',
        source: 'getPostListSlice response payload',
      );

      return PostListSliceModel.fromJson(body);
    });
  }

  @override
  Future<PostModel> getPostById(String postId) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/posts/$postId');
      final body = JsonReader.asObject(
        response.data,
        'response',
        source: 'getPostById response payload',
      );

      return PostModel.fromJson(body);
    });
  }
}
