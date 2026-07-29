import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/failures/post_failure_messages.dart';
import 'package:social_app/features/post/domain/repositories/post_repository.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// Validates post input data and delegates post creation to the repository.
class CreatePostUseCase implements UseCase<Post, CreatePostParams> {
  /// Creates a [CreatePostUseCase].
  CreatePostUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  /// Repository used to persist the new post.
  final PostRepository _postRepository;

  @override
  /// Validates the request, then creates the post if the data is valid.
  Future<Either<Failure, Post>> call(CreatePostParams params) async {
    if (params.image.path.isEmpty) {
      return left(const ValidationFailure(PostFailureMessages.imageRequired));
    }
    if (params.title.isEmpty) {
      return left(const ValidationFailure(PostFailureMessages.titleRequired));
    }
    if (params.content.isEmpty) {
      return left(
        const ValidationFailure(PostFailureMessages.contentRequired),
      );
    }
    if (params.topics.isEmpty) {
      return left(
        const ValidationFailure(PostFailureMessages.topicSelectionRequired),
      );
    }

    return _postRepository.createPost(
      image: params.image,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

/// Parameters required to create a new post post.
class CreatePostParams {
  /// Creates a [CreatePostParams].
  CreatePostParams({
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

  /// Post title.
  final String title;

  /// Post content body.
  final String content;

  /// Selected cover image file.
  final File image;

  /// Selected topics attached to the post.
  final List<PostTopic> topics;
}
