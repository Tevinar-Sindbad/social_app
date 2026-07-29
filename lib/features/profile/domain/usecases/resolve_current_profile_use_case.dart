import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_app/features/profile/domain/results/current_profile_result.dart';

/// Resolves the current authenticated user's profile using the profile
/// feature's remote-plus-cache policy.
class ResolveCurrentProfileUseCase
    implements NoParamsUseCase<CurrentProfileResult> {
  /// Creates a [ResolveCurrentProfileUseCase].
  ResolveCurrentProfileUseCase({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  /// Resolves the current profile state for the authenticated user.
  @override
  Future<Either<Failure, CurrentProfileResult>> call() {
    return _profileRepository.resolveCurrentProfile();
  }
}
