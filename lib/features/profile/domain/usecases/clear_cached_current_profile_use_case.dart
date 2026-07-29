import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';

/// Clears the locally cached current profile projection.
class ClearCachedCurrentProfileUseCase implements NoParamsUseCase<void> {
  /// Creates a [ClearCachedCurrentProfileUseCase].
  ClearCachedCurrentProfileUseCase({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _profileRepository.clearCachedCurrentProfile();
  }
}
