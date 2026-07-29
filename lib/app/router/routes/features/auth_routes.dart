part of '../routes.dart';

/// Path for the sign-in route.
const signInRoutePath = '/sign-in';

/// Path for the sign-up route.
const signUpRoutePath = '/sign-up';

/// Path for the email-confirmation pending route.
const confirmEmailRoutePath = '/confirm-email';

/// Query parameter key carrying the pending confirmation email address.
const confirmEmailRouteEmailQueryKey = 'email';

/// Route to the sign-in screen for unauthenticated users.
///
/// This route sits outside the signed-in shell so redirects can send logged-out
/// users here without mounting any authenticated navigation state.
@TypedGoRoute<SignInPageRoute>(path: signInRoutePath)
class SignInPageRoute extends GoRouteData with $SignInPageRoute {
  /// Creates a [SignInPageRoute].
  const SignInPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignInPage();
}

/// Route to the sign-up screen for creating a new account.
///
/// Like [SignInPageRoute], this route stays outside the signed-in shell and is
/// only reachable while the app is in an unauthenticated state.
@TypedGoRoute<SignUpPageRoute>(path: signUpRoutePath)
class SignUpPageRoute extends GoRouteData with $SignUpPageRoute {
  /// Creates a [SignUpPageRoute].
  const SignUpPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}

/// Route shown after sign-up while waiting for email confirmation.
@TypedGoRoute<EmailConfirmationPendingPageRoute>(path: confirmEmailRoutePath)
class EmailConfirmationPendingPageRoute extends GoRouteData
    with $EmailConfirmationPendingPageRoute {
  /// Creates a [EmailConfirmationPendingPageRoute].
  const EmailConfirmationPendingPageRoute({required this.email});

  /// Email address waiting for confirmation.
  final String email;

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) => EmailConfirmationPendingPage(email: email);
}
