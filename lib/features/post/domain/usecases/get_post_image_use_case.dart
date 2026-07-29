import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';

/// Retrieves the locally cached or downloaded image file for a post.
class GetPostImageUseCase implements UseCase<File?, Post> {
  /// Creates a [GetPostImageUseCase].
  GetPostImageUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  /// Loads the image associated with [post].
  Future<Either<Failure, File?>> call(Post post) {
    return _postRepository.getPostImage(post);
  }
}
