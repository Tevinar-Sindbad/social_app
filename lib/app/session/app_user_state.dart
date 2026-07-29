part of 'app_user_cubit.dart';

/// Represents app user state.
@immutable
sealed class AppUserState {
  const AppUserState();
}

/// An app user loading.
final class AppUserLoading extends AppUserState {}

/// An app user signed out.
final class AppUserSignedOut extends AppUserState {}

/// A signed-out auth flow that is waiting for email confirmation.
final class AppUserAwaitingEmailConfirmation extends AppUserState {
  /// Creates an [AppUserAwaitingEmailConfirmation].
  const AppUserAwaitingEmailConfirmation({required this.email});

  /// Email address waiting for confirmation.
  final String email;
}

/// An authenticated user who still needs to create their app profile.
///
/// The auth identity is carried in state so onboarding refresh logic can
/// rebuild the signed-in app user without relying on hidden cubit fields.
final class AppUserNeedsOnboarding extends AppUserState {
  /// Creates an [AppUserNeedsOnboarding].
  const AppUserNeedsOnboarding(this.identity);

  /// Auth identity attached to the current authenticated session.
  final AuthIdentity identity;
}

/// An app user signed in.
final class AppUserSignedIn extends AppUserState {
  /// Creates a [AppUserSignedIn].
  const AppUserSignedIn(this.user);

  /// The user.
  final SignedInAppUser user;
}

/// Represents app user failure.
final class AppUserFailure extends AppUserState {
  /// Creates a [AppUserFailure].
  const AppUserFailure(this.error);

  /// The error.
  final String error;
}
