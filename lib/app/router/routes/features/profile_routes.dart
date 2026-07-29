part of '../routes.dart';

/// Path for the profile-name onboarding route.
const profileNameOnboardingRoutePath = '/onboarding/profile-name';

/// Route to the first profile-name onboarding step.
@TypedGoRoute<ProfileNameOnboardingPageRoute>(
  path: profileNameOnboardingRoutePath,
)
class ProfileNameOnboardingPageRoute extends GoRouteData
    with $ProfileNameOnboardingPageRoute {
  /// Creates a [ProfileNameOnboardingPageRoute].
  const ProfileNameOnboardingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileNameOnboardingPage();
}
