import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';

/// Observes one post by its stable identifier.
class ObservePostByIdUseCase
    implements StreamUseCase<Either<Failure, Post>, String> {
  /// Creates an [ObservePostByIdUseCase].
  ObservePostByIdUseCase(this.repository);

  /// Repository used to load and refresh post details.
  final PostRepository repository;

  @override
  /// Starts observing the post identified by [postId].
  Stream<Either<Failure, Post>> call(String postId) {
    return repository.observePostById(postId);
  }
}
