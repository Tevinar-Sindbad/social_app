/// Auth-provider identity exposed by Supabase for the current session.
class AuthIdentity {
  /// Creates an [AuthIdentity].
  const AuthIdentity({
    required this.id,
    required this.email,
  });

  /// Stable Supabase user identifier.
  final String id;

  /// Verified email address attached to the authenticated session.
  final String email;
}
