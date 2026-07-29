import 'package:social_app/features/auth/domain/entities/auth_identity.dart';

/// Stable application-facing representation of authentication session changes.
sealed class AuthSessionChange {
  /// Creates an [AuthSessionChange].
  const AuthSessionChange();
}

/// First session snapshot emitted during app bootstrap.
final class InitialSession extends AuthSessionChange {
  /// Creates an [InitialSession].
  const InitialSession(this.identity);

  /// Auth identity attached to the current local session, when available.
  final AuthIdentity? identity;
}

/// A user signed in successfully.
final class SignedIn extends AuthSessionChange {
  /// Creates a [SignedIn].
  const SignedIn(this.identity);

  /// Auth identity attached to the current local session.
  final AuthIdentity identity;
}

/// The local session was cleared.
final class SignedOut extends AuthSessionChange {
  /// Creates a [SignedOut].
  const SignedOut();
}
