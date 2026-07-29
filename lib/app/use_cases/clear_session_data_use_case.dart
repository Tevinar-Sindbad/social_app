import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/usecases/clear_post_cache_use_case.dart';

/// Clears all locally cached feature data tied to the current auth session.
///
/// Extend this use case by composing additional feature-specific cache clear
/// use cases here as more features adopt local caching.
class ClearSessionDataUseCase implements NoParamsUseCase<void> {
  /// Creates a [ClearSessionDataUseCase].
  ClearSessionDataUseCase({
    required ClearPostCacheUseCase clearPostCacheUseCase,
  }) : _clearPostCacheUseCase = clearPostCacheUseCase;

  final ClearPostCacheUseCase _clearPostCacheUseCase;

  @override
  Future<Either<Failure, void>> call() async {
    return _clearPostCacheUseCase();
  }
}
