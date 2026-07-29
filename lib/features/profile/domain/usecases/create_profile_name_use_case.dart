import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';

/// Creates the first app-owned profile name for the authenticated user.
class CreateProfileNameUseCase implements UseCase<Profile, String> {
  /// Creates a [CreateProfileNameUseCase].
  CreateProfileNameUseCase({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<Either<Failure, Profile>> call(String params) {
    return _profileRepository.createProfileName(
      name: params.trim(),
    );
  }
}
