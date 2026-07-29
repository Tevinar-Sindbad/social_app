/// App-session projection representing the currently signed-in application
/// user.
class SignedInAppUser {
  /// Creates a [SignedInAppUser].
  const SignedInAppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Unique internal user identifier (not the Supabase one).
  final String id;

  /// Display name shown in the UI.
  final String name;

  /// Email address associated with the account.
  final String email;
}
