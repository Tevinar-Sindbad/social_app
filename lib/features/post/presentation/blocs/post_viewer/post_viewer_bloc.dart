import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/usecases/get_post_image_use_case.dart';
import 'package:social_app/features/post/domain/usecases/observe_post_by_id_use_case.dart';

part 'post_viewer_event.dart';
part 'post_viewer_state.dart';

/// This bloc observes a single post and provides it to the UI.
class PostViewerBloc extends Bloc<PostViewerEvent, PostViewerState> {
  /// Creates a [PostViewerBloc].
  PostViewerBloc({
    required ObservePostByIdUseCase observePostByIdUseCase,
    required GetPostImageUseCase getPostImageUseCase,
  }) : _observePostByIdUseCase = observePostByIdUseCase,
       _getPostImageUseCase = getPostImageUseCase,
       super(PostViewerInitial()) {
    on<LoadPost>(_loadPost);
    on<_PostReceived>(_onPostReceived);
  }

  final ObservePostByIdUseCase _observePostByIdUseCase;
  final GetPostImageUseCase _getPostImageUseCase;
  StreamSubscription<Either<Failure, Post>>? _postSubscription;

  @override
  Future<void> close() async {
    await _postSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadPost(
    LoadPost event,
    Emitter<PostViewerState> emit,
  ) async {
    await _postSubscription?.cancel();
    emit(PostViewerLoading());

    _postSubscription = _observePostByIdUseCase(event.postId).listen(
      (result) => add(_PostReceived(result)),
    );
  }

  Future<void> _onPostReceived(
    _PostReceived event,
    Emitter<PostViewerState> emit,
  ) async {
    await event.result.fold<Future<void>>(
      (failure) async {
        if (state is PostViewerSuccess) {
          return;
        }

        emit(PostViewerFailure(error: failure.message));
      },
      (post) async {
        final imageResult = await _getPostImageUseCase(post);
        final imageFile = imageResult.getOrElse((_) => null);

        emit(
          PostViewerSuccess(
            post: post,
            imageFile: imageFile,
          ),
        );
      },
    );
  }
}
