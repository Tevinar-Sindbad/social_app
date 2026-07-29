import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/core/logging/app_talker_logger.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';
import 'package:social_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:social_app/features/profile/data/sources/profile_local_data_source.dart';
import 'package:social_app/features/profile/data/sources/profile_remote_data_source.dart';
import 'package:social_app/features/profile/domain/results/current_profile_result.dart';

class MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockAppTalkerLogger extends Mock implements AppTalkerLogger {}

void main() {
  late MockProfileLocalDataSource localDataSource;
  late MockProfileRemoteDataSource remoteDataSource;
  late MockAppTalkerLogger logger;
  late ProfileRepositoryImpl repository;

  const profileModel = ProfileModel(id: 'user-1', name: 'Alice');

  setUp(() {
    localDataSource = MockProfileLocalDataSource();
    remoteDataSource = MockProfileRemoteDataSource();
    logger = MockAppTalkerLogger();

    repository = ProfileRepositoryImpl(
      profileLocalDataSource: localDataSource,
      profileRemoteDataSource: remoteDataSource,
      logger: logger,
    );
  });

  group('resolveCurrentProfile', () {
    test(
      'given a successful remote fetch then caches the profile and returns it',
      () async {
        when(
          () => remoteDataSource.getCurrentProfile(),
        ).thenAnswer((_) async => profileModel);
        when(
          () => localDataSource.saveCurrentProfile(profileModel),
        ).thenAnswer((_) async {});

        final result = await repository.resolveCurrentProfile();

        result.fold(
          (_) => fail('Expected a successful result'),
          (resolved) {
            expect(resolved, isA<CurrentProfile>());
            final currentProfile = resolved as CurrentProfile;
            expect(currentProfile.profile.id, 'user-1');
            expect(currentProfile.profile.name, 'Alice');
          },
        );
        verify(
          () => localDataSource.saveCurrentProfile(profileModel),
        ).called(1);
        verifyNever(() => localDataSource.getCurrentProfile());
      },
    );

    test(
      'given profile_not_found from remote then clears the cache and returns '
      'CurrentProfileMissing',
      () async {
        when(
          () => remoteDataSource.getCurrentProfile(),
        ).thenThrow(_profileNotFoundException());
        when(
          () => localDataSource.clearCurrentProfile(),
        ).thenAnswer((_) async {});

        final result = await repository.resolveCurrentProfile();

        result.fold(
          (_) => fail('Expected a successful result'),
          (resolved) => expect(resolved, isA<CurrentProfileMissing>()),
        );
        verify(() => localDataSource.clearCurrentProfile()).called(1);
      },
    );

    test(
      'given a network failure and a cached profile then returns the cached '
      'profile',
      () async {
        when(
          () => remoteDataSource.getCurrentProfile(),
        ).thenThrow(const RemoteNetworkException(message: 'offline'));
        when(
          () => localDataSource.getCurrentProfile(),
        ).thenAnswer((_) async => profileModel);

        final result = await repository.resolveCurrentProfile();

        result.fold(
          (_) => fail('Expected a cached profile fallback'),
          (resolved) {
            expect(resolved, isA<CurrentProfile>());
            final currentProfile = resolved as CurrentProfile;
            expect(currentProfile.profile.name, 'Alice');
          },
        );
      },
    );

    test(
      'given a network failure and no cached profile then returns the mapped '
      'failure',
      () async {
        when(
          () => remoteDataSource.getCurrentProfile(),
        ).thenThrow(const RemoteNetworkException(message: 'offline'));
        when(
          () => localDataSource.getCurrentProfile(),
        ).thenAnswer((_) async => null);

        final result = await repository.resolveCurrentProfile();

        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected a failure result'),
        );
      },
    );
  });

  group('createProfileName', () {
    test(
      'given a successful remote creation then caches the profile and returns '
      'the entity',
      () async {
        when(
          () => remoteDataSource.createProfileName(name: 'Alice'),
        ).thenAnswer((_) async => profileModel);
        when(
          () => localDataSource.saveCurrentProfile(profileModel),
        ).thenAnswer((_) async {});

        final result = await repository.createProfileName(name: 'Alice');

        result.fold(
          (_) => fail('Expected a successful result'),
          (profile) {
            expect(profile.id, 'user-1');
            expect(profile.name, 'Alice');
          },
        );
        verify(
          () => localDataSource.saveCurrentProfile(profileModel),
        ).called(1);
      },
    );
  });
}

RemoteServerException _profileNotFoundException() {
  return RemoteServerException(
    message: 'Profile not found',
    code: 'profile_not_found',
    statusCode: 404,
    path: '/profile',
    timestamp: DateTime.parse('2026-06-29T12:00:00.000Z'),
  );
}
