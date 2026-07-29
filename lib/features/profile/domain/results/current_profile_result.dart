import 'package:social_app/features/profile/domain/entities/profile.dart';

/// Semantic result of resolving the current authenticated user's profile.
sealed class CurrentProfileResult {
  /// Creates a [CurrentProfileResult].
  const CurrentProfileResult();
}

/// Profile resolution succeeded with one usable profile projection.
final class CurrentProfile extends CurrentProfileResult {
  /// Creates a [CurrentProfile].
  const CurrentProfile(this.profile);

  /// Resolved profile projection.
  final Profile profile;
}

/// The authenticated user has no app-owned profile yet.
final class CurrentProfileMissing extends CurrentProfileResult {
  /// Creates a [CurrentProfileMissing].
  const CurrentProfileMissing();
}
