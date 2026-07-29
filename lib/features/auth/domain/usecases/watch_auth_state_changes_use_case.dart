import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/events/auth_session_change.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Watches authentication state changes.
class WatchAuthStateChanges
    implements NoParamsStreamUseCase<Either<Failure, AuthSessionChange>> {
  /// Creates a [WatchAuthStateChanges].
  WatchAuthStateChanges({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Stream<Either<Failure, AuthSessionChange>> call() {
    return _authRepository.authStateChanges();
  }
}
