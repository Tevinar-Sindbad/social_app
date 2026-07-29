import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

part 'post_editor_event.dart';
part 'post_editor_state.dart';

/// A post editor bloc.
class PostEditorBloc extends Bloc<PostEditorEvent, PostEditorState> {
  /// Creates a [PostEditorBloc].
  PostEditorBloc({required CreatePostUseCase uploadPost})
    : _uploadPost = uploadPost,
      super(const PostInitial()) {
    on<PostEditorEvent>((event, emit) => emit(const PostLoading()));
    on<AddPost>(_onAddPost);
  }
  final CreatePostUseCase _uploadPost;

  Future<void> _onAddPost(AddPost event, Emitter<PostEditorState> emit) async {
    final res = await _uploadPost.call(
      CreatePostParams(
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );
    res.fold(
      (l) => emit(PostFailure(l.message)),
      (r) => emit(PostUploadSuccess(r)),
    );
  }
}
