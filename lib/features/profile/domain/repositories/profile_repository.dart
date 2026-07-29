import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/results/current_profile_result.dart';

/// Coordinates backend profile reads and writes for the authenticated user.
abstract interface class ProfileRepository {
  /// Resolves the current authenticated user's profile using the profile
  /// feature's remote-plus-cache policy.
  Future<Either<Failure, CurrentProfileResult>> resolveCurrentProfile();

  /// Creates the first profile name for the authenticated user.
  Future<Either<Failure, Profile>> createProfileName({
    required String name,
  });

  /// Clears the locally cached current profile projection.
  Future<Either<Failure, void>> clearCachedCurrentProfile();
}
