import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';

/// Central router configuration for the application.
///
/// The full route hierarchy lives in the typed route declarations under
/// `lib/app/router/routes`, and is exposed here through `$appRoutes`.
///
/// This class is only responsible for creating the [GoRouter] instance and
/// attaching app-wide behavior such as auth-driven refreshes and redirects.
class AppRouter {
  /// Shared router instance for the app.
  ///
  /// The router listens to [AppUserCubit] so auth-state changes immediately
  /// re-evaluate redirects.
  static final router = GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: const InitialLoadingPageRoute().location,
    routes: $appRoutes,

    // The top-level callback allows the app to redirect to a new location.
    redirect: (context, state) => resolveAppRedirect(
      appUserState: context.read<AppUserCubit>().state,
      matchedLocation: state.matchedLocation,
      confirmEmailQuery:
          state.uri.queryParameters[confirmEmailRouteEmailQueryKey],
    ),
  );
}

/// Resolves the next auth-driven route for the given app-user state snapshot.
///
/// Production routing goes through [AppRouter.router]; this function is exposed
/// so redirect precedence can be verified with focused unit tests.
@visibleForTesting
String? resolveAppRedirect({
  required AppUserState appUserState,
  required String matchedLocation,
  String? confirmEmailQuery,
}) {
  final hasConfirmEmailQuery =
      confirmEmailQuery != null && confirmEmailQuery.isNotEmpty;
  final isConfirmEmailRoute = matchedLocation == confirmEmailRoutePath;
  final isAuthRoute =
      matchedLocation == signInRoutePath ||
      matchedLocation == signUpRoutePath ||
      isConfirmEmailRoute;

  return _redirectForInvalidConfirmEmailRoute(
        isConfirmEmailRoute: isConfirmEmailRoute,
        hasConfirmEmailQuery: hasConfirmEmailQuery,
      ) ??
      _redirectForAwaitingEmailConfirmation(
        appUserState: appUserState,
        isConfirmEmailRoute: isConfirmEmailRoute,
        confirmEmailQuery: confirmEmailQuery,
      ) ??
      _redirectForSignedOut(
        appUserState: appUserState,
        isAuthRoute: isAuthRoute,
      ) ??
      _redirectForNeedsOnboarding(
        appUserState: appUserState,
        matchedLocation: matchedLocation,
      ) ??
      _redirectForSignedIn(
        appUserState: appUserState,
        matchedLocation: matchedLocation,
        isAuthRoute: isAuthRoute,
      );
}

String? _redirectForInvalidConfirmEmailRoute({
  required bool isConfirmEmailRoute,
  required bool hasConfirmEmailQuery,
}) {
  if (isConfirmEmailRoute && !hasConfirmEmailQuery) {
    return signInRoutePath;
  }

  return null;
}

String? _redirectForAwaitingEmailConfirmation({
  required AppUserState appUserState,
  required bool isConfirmEmailRoute,
  required String? confirmEmailQuery,
}) {
  if (appUserState is! AppUserAwaitingEmailConfirmation) {
    return null;
  }

  if (isConfirmEmailRoute && confirmEmailQuery == appUserState.email) {
    return null;
  }

  return EmailConfirmationPendingPageRoute(
    email: appUserState.email,
  ).location;
}

String? _redirectForSignedOut({
  required AppUserState appUserState,
  required bool isAuthRoute,
}) {
  if (appUserState is! AppUserSignedOut) {
    return null;
  }

  if (isAuthRoute) {
    return null;
  }

  return signInRoutePath;
}

String? _redirectForNeedsOnboarding({
  required AppUserState appUserState,
  required String matchedLocation,
}) {
  if (appUserState is! AppUserNeedsOnboarding) {
    return null;
  }

  if (matchedLocation == profileNameOnboardingRoutePath) {
    return null;
  }

  return profileNameOnboardingRoutePath;
}

String? _redirectForSignedIn({
  required AppUserState appUserState,
  required String matchedLocation,
  required bool isAuthRoute,
}) {
  if (appUserState is! AppUserSignedIn) {
    return null;
  }

  if (isAuthRoute ||
      matchedLocation == initialLoadingRoutePath ||
      matchedLocation == profileNameOnboardingRoutePath) {
    return postsRoutePath;
  }

  return null;
}
