import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/events/auth_session_change.dart';

/// Coordinates Supabase authentication and local session observation.
abstract interface class AuthRepository {
  /// Returns the authenticated identity changes stream.
  Stream<Either<Failure, AuthSessionChange>> authStateChanges();

  /// Returns auth-flow failures that should be surfaced by auth UI screens.
  Stream<Failure> authFlowFailures();

  /// Signs up with email and password.
  Future<Either<Failure, void>> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  /// Signs in with email and password.
  Future<Either<Failure, void>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Resends the sign-up email confirmation message.
  Future<Either<Failure, void>> resendSignUpConfirmationEmail({
    required String email,
  });

  /// Sign out.
  Future<Either<Failure, void>> signOut();
}
