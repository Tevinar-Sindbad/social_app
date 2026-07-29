import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/app/router/app_router.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/app/session/signed_in_app_user.dart';
import 'package:social_app/features/auth/domain/entities/auth_identity.dart';

void main() {
  group('resolveAppRedirect', () {
    test(
      'given confirm-email route without email query when resolving then '
      'redirects to sign in',
      () {
        final redirect = resolveAppRedirect(
          appUserState: AppUserSignedOut(),
          matchedLocation: confirmEmailRoutePath,
        );

        expect(redirect, signInRoutePath);
      },
    );

    test(
      'given awaiting-email state when confirm-email route matches email then '
      'keeps current route',
      () {
        const email = 'alice@example.com';

        final redirect = resolveAppRedirect(
          appUserState: const AppUserAwaitingEmailConfirmation(email: email),
          matchedLocation: confirmEmailRoutePath,
          confirmEmailQuery: email,
        );

        expect(redirect, isNull);
      },
    );

    test(
      'given awaiting-email state when resolving from another route then '
      'redirects to confirm-email',
      () {
        const email = 'alice@example.com';

        final redirect = resolveAppRedirect(
          appUserState: const AppUserAwaitingEmailConfirmation(email: email),
          matchedLocation: signInRoutePath,
        );

        expect(
          redirect,
          const EmailConfirmationPendingPageRoute(email: email).location,
        );
      },
    );

    test(
      'given signed-out state when resolving an auth route then keeps current '
      'route',
      () {
        final redirect = resolveAppRedirect(
          appUserState: AppUserSignedOut(),
          matchedLocation: signUpRoutePath,
        );

        expect(redirect, isNull);
      },
    );

    test(
      'given signed-out state when resolving a protected route then '
      'redirects to sign in',
      () {
        final redirect = resolveAppRedirect(
          appUserState: AppUserSignedOut(),
          matchedLocation: postsRoutePath,
        );

        expect(redirect, signInRoutePath);
      },
    );

    test(
      'given needs-onboarding state when resolving another route then '
      'redirects to onboarding',
      () {
        final redirect = resolveAppRedirect(
          appUserState: const AppUserNeedsOnboarding(
            AuthIdentity(id: 'auth-1', email: 'alice@example.com'),
          ),
          matchedLocation: postsRoutePath,
        );

        expect(redirect, profileNameOnboardingRoutePath);
      },
    );

    test(
      'given signed-in state when resolving an auth route then redirects to '
      'posts',
      () {
        final redirect = resolveAppRedirect(
          appUserState: const AppUserSignedIn(
            SignedInAppUser(
              id: 'user-1',
              name: 'Alice',
              email: 'alice@example.com',
            ),
          ),
          matchedLocation: signInRoutePath,
        );

        expect(redirect, postsRoutePath);
      },
    );

    test(
      'given loading state when resolving initial-loading route then keeps '
      'current route',
      () {
        final redirect = resolveAppRedirect(
          appUserState: AppUserLoading(),
          matchedLocation: initialLoadingRoutePath,
        );

        expect(redirect, isNull);
      },
    );
  });
}
