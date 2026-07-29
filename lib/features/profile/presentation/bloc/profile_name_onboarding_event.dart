part of 'profile_name_onboarding_bloc.dart';

@immutable
/// Represents profile-name onboarding events.
abstract class ProfileNameOnboardingEvent {}

/// User intent: submit the first profile name during onboarding.
final class ProfileNameOnboardingSubmit extends ProfileNameOnboardingEvent {
  /// Creates a [ProfileNameOnboardingSubmit].
  ProfileNameOnboardingSubmit({
    required this.name,
  });

  /// Submitted profile name.
  final String name;
}
