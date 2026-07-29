import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';
import 'package:social_app/features/profile/data/sources/profile_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ProfileRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = ProfileRemoteDataSourceImpl(dio: dio);
  });

  group('getCurrentProfile', () {
    test(
      'given a valid backend body then returns the parsed profile model',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>('/profile'),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/profile'),
            data: const {
              'id': 'user-1',
              'name': 'Alice',
            },
          ),
        );

        final result = await dataSource.getCurrentProfile();

        expect(result.id, 'user-1');
        expect(result.name, 'Alice');
        verify(() => dio.get<Map<String, dynamic>>('/profile')).called(1);
      },
    );

    test(
      'given an empty backend body then throws InvalidResponseException',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>('/profile'),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/profile'),
          ),
        );

        expect(
          dataSource.getCurrentProfile,
          throwsA(isA<RemoteInvalidResponseException>()),
        );
      },
    );
  });

  group('createProfileName', () {
    test(
      'given a valid backend body then posts the name and returns the parsed '
      'profile model',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/profile/name',
            data: {
              'name': 'Alice',
            },
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/profile/name'),
            data: const {
              'id': 'user-1',
              'name': 'Alice',
            },
          ),
        );

        final result = await dataSource.createProfileName(name: 'Alice');

        expect(result, isA<ProfileModel>());
        expect(result.name, 'Alice');
        verify(
          () => dio.post<Map<String, dynamic>>(
            '/profile/name',
            data: {
              'name': 'Alice',
            },
          ),
        ).called(1);
      },
    );

    test(
      'given an empty backend body then throws InvalidResponseException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/profile/name',
            data: {
              'name': 'Alice',
            },
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/profile/name'),
          ),
        );

        expect(
          () => dataSource.createProfileName(name: 'Alice'),
          throwsA(isA<RemoteInvalidResponseException>()),
        );
      },
    );
  });
}
