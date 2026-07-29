import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Watches auth-flow failures that should be surfaced by auth UI.
class WatchAuthFlowFailuresUseCase implements NoParamsStreamUseCase<Failure> {
  /// Creates a [WatchAuthFlowFailuresUseCase].
  WatchAuthFlowFailuresUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Stream<Failure> call() {
    return _authRepository.authFlowFailures();
  }
}
