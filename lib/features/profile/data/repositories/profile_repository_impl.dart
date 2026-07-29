import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/core/logging/app_talker_logger.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';
import 'package:social_app/features/profile/data/sources/profile_local_data_source.dart';
import 'package:social_app/features/profile/data/sources/profile_remote_data_source.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/failures/profile_failures_mapper.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_app/features/profile/domain/results/current_profile_result.dart';

/// Concrete [ProfileRepository] backed by backend profile endpoints.
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates a [ProfileRepositoryImpl].
  const ProfileRepositoryImpl({
    required ProfileLocalDataSource profileLocalDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required AppTalkerLogger logger,
  }) : _profileLocalDataSource = profileLocalDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _logger = logger;

  final ProfileLocalDataSource _profileLocalDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final AppTalkerLogger _logger;

  @override
  Future<Either<Failure, CurrentProfileResult>> resolveCurrentProfile() async {
    try {
      final profileModel = await _profileRemoteDataSource.getCurrentProfile();
      await _saveCachedCurrentProfile(profileModel);
      return right(CurrentProfile(profileModel.toEntity()));
    } on Exception catch (error, stackTrace) {
      if (error is RemoteServerException && error.code == 'profile_not_found') {
        await _clearCachedCurrentProfileBestEffort();
        return right(const CurrentProfileMissing());
      }

      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in ProfileRepositoryImpl.resolveCurrentProfile.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (failure is NetworkFailure || failure is UnexpectedFailure) {
        final cachedProfile = await _getCachedCurrentProfile();
        if (cachedProfile != null) {
          return right(CurrentProfile(cachedProfile));
        }
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, Profile>> createProfileName({
    required String name,
  }) async {
    try {
      final profileModel = await _profileRemoteDataSource.createProfileName(
        name: name,
      );
      await _saveCachedCurrentProfile(profileModel);
      return right(profileModel.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in ProfileRepositoryImpl.createProfileName.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedCurrentProfile() async {
    try {
      await _profileLocalDataSource.clearCurrentProfile();
      return right(null);
    } on Exception catch (error, stackTrace) {
      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'ProfileRepositoryImpl.clearCachedCurrentProfile.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  Future<Profile?> _getCachedCurrentProfile() async {
    try {
      final profile = await _profileLocalDataSource.getCurrentProfile();
      return profile?.toEntity();
    } on Exception catch (error, stackTrace) {
      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'ProfileRepositoryImpl._getCachedCurrentProfile.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return null;
    }
  }

  Future<void> _saveCachedCurrentProfile(ProfileModel profile) async {
    try {
      await _profileLocalDataSource.saveCurrentProfile(profile);
    } on Exception catch (error, stackTrace) {
      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'ProfileRepositoryImpl._saveCachedCurrentProfile.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _clearCachedCurrentProfileBestEffort() async {
    try {
      await _profileLocalDataSource.clearCurrentProfile();
    } on Exception catch (error, stackTrace) {
      final failure = mapProfileExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        _logger.error(
          'Unexpected error in '
          'ProfileRepositoryImpl._clearCachedCurrentProfileBestEffort.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
