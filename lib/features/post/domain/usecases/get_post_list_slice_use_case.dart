import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failure_messages.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/read_models/post_list_slice.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';

/// Loads one cursor-based post list slice as a one-shot request.
class GetPostListSliceUseCase
    implements UseCase<PostListSlice, GetPostListSliceParams> {
  /// Creates a [GetPostListSliceUseCase].
  GetPostListSliceUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  /// Repository used to load remote list slices.
  final PostRepository _postRepository;

  @override
  /// Validates the requested slice size, then loads the list slice.
  Future<Either<Failure, PostListSlice>> call(
    GetPostListSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure(CommonFailureMessages.invalidLimit)),
      );
    }

    return _postRepository.getPostListSlice(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one post-list slice.
class GetPostListSliceParams {
  /// Creates a [GetPostListSliceParams].
  const GetPostListSliceParams({
    required this.limit,
    this.cursor,
  });

  /// Maximum number of posts to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
