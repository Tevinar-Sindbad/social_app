part of 'profile_name_onboarding_bloc.dart';

@immutable
/// Represents profile-name onboarding state.
abstract class ProfileNameOnboardingState {
  /// Creates a [ProfileNameOnboardingState].
  const ProfileNameOnboardingState();
}

/// Idle state when no onboarding submission is currently running.
final class ProfileNameOnboardingIdle extends ProfileNameOnboardingState {}

/// Loading state while the profile-name onboarding submission is in flight.
final class ProfileNameOnboardingLoading extends ProfileNameOnboardingState {}

/// Success state after the onboarding profile name has been created.
final class ProfileNameOnboardingSuccess extends ProfileNameOnboardingState {}

/// Failure state for onboarding submission errors.
final class ProfileNameOnboardingFailure extends ProfileNameOnboardingState {
  /// Creates a [ProfileNameOnboardingFailure].
  const ProfileNameOnboardingFailure(this.message);

  /// User-facing error message.
  final String message;
}
