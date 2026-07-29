import 'package:dio/dio.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_mapper.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';

/// Remote boundary for backend profile requests.
abstract interface class ProfileRemoteDataSource {
  /// Reads the current authenticated user's profile.
  Future<ProfileModel> getCurrentProfile();

  /// Creates the first profile name for the authenticated user.
  Future<ProfileModel> createProfileName({
    required String name,
  });
}

/// Dio-backed implementation of [ProfileRemoteDataSource].
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  /// Creates a [ProfileRemoteDataSourceImpl].
  const ProfileRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<ProfileModel> getCurrentProfile() {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/profile');
      final body = JsonReader.asObject(
        response.data,
        'response',
        source: 'getCurrentProfile response payload',
      );

      return ProfileModel.fromJson(body);
    });
  }

  @override
  Future<ProfileModel> createProfileName({
    required String name,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/profile/name',
        data: {
          'name': name,
        },
      );
      final body = JsonReader.asObject(
        response.data,
        'response',
        source: 'createProfileName response payload',
      );

      return ProfileModel.fromJson(body);
    });
  }
}
