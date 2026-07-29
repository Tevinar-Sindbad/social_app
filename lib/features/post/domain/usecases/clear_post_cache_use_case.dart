import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';

/// Clears locally cached post data for the current session.
class ClearPostCacheUseCase implements NoParamsUseCase<void> {
  /// Creates a [ClearPostCacheUseCase].
  ClearPostCacheUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _postRepository.clearLocalCache();
  }
}
