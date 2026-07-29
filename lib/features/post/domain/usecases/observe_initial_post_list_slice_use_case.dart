import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/read_models/post_list_slice.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';

/// Observes the initial post list slice with cache-first behavior.
class ObserveInitialPostListSliceUseCase
    implements NoParamsStreamUseCase<Either<Failure, PostListSlice>> {
  /// Creates an [ObserveInitialPostListSliceUseCase].
  ObserveInitialPostListSliceUseCase({required this.postRepository});

  /// Repository used to observe paged post snapshots.
  final PostRepository postRepository;

  @override
  /// Starts observing the initial post list slice.
  Stream<Either<Failure, PostListSlice>> call() {
    return postRepository.observeInitialPostListSlice(limit: 20);
  }
}
