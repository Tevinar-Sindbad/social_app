import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/read_models/post_list_slice.dart';
import 'package:social_app/features/post/domain/usecases/get_post_list_slice_use_case.dart';
import 'package:social_app/features/post/domain/usecases/observe_initial_post_list_slice_use_case.dart';

part 'post_list_event.dart';
part 'post_list_state.dart';

/// Bloc responsible for loading, paginating, and refreshing the post list.
class PostListBloc extends Bloc<PostListEvent, PostListState> {
  /// Creates a [PostListBloc].
  PostListBloc({
    required ObserveInitialPostListSliceUseCase
    observeInitialPostListSliceUseCase,
    required GetPostListSliceUseCase getPostListSliceUseCase,
  }) : _observeInitialPostListSliceUseCase = observeInitialPostListSliceUseCase,
       _getPostListSliceUseCase = getPostListSliceUseCase,
       super(
         const PostListLoading(
           posts: [],
           nextCursor: null,
           isFromCache: false,
           refreshError: null,
         ),
       ) {
    on<LoadInitialList>(_onLoadInitialList);
    on<LoadMoreList>(_onLoadMoreList, transformer: droppable());
    on<RefreshList>(_onRefreshList);
    on<PrependCreatedPost>(_onPrependCreatedPost);
    on<_InitialListSliceReceived>(_onInitialListSliceReceived);

    add(const LoadInitialList());
  }

  static const int _pageSize = 20;

  final ObserveInitialPostListSliceUseCase _observeInitialPostListSliceUseCase;
  final GetPostListSliceUseCase _getPostListSliceUseCase;

  StreamSubscription<Either<Failure, PostListSlice>>? _listSliceSubscription;

  @override
  Future<void> close() async {
    await _listSliceSubscription?.cancel();
    await super.close();
  }

  Future<void> _onLoadInitialList(
    LoadInitialList event,
    Emitter<PostListState> emit,
  ) async {
    // Prevents duplicate listeners on the same post-list stream when
    // refreshing the list.
    await _listSliceSubscription?.cancel();

    if (state.posts.isEmpty) {
      emit(
        const PostListLoading(
          posts: [],
          nextCursor: null,
          isFromCache: false,
          refreshError: null,
        ),
      );
    } else {
      emit(
        PostListSuccess(
          posts: state.posts,
          nextCursor: state.nextCursor,
          isFromCache: state.isFromCache,
          refreshError: null,
        ),
      );
    }
    _listSliceSubscription = _observeInitialPostListSliceUseCase().listen(
      (result) => add(_InitialListSliceReceived(result)),
    );
  }

  Future<void> _onRefreshList(
    RefreshList event,
    Emitter<PostListState> emit,
  ) async {
    add(const LoadInitialList());
  }

  void _onPrependCreatedPost(
    PrependCreatedPost event,
    Emitter<PostListState> emit,
  ) {
    final updatedPosts = [
      event.post,
      ...state.posts.where((post) => post.id != event.post.id),
    ];

    emit(
      PostListSuccess(
        posts: updatedPosts,
        nextCursor: state.nextCursor,
        isFromCache: state.isFromCache,
        refreshError: state.refreshError,
      ),
    );
  }

  Future<void> _onLoadMoreList(
    LoadMoreList event,
    Emitter<PostListState> emit,
  ) async {
    final cursor = state.nextCursor;
    if (cursor == null) {
      return;
    }

    final existingPosts = state.posts;
    final nextCursor = state.nextCursor;
    final isFromCache = state.isFromCache;

    emit(
      PostListLoading(
        posts: existingPosts,
        nextCursor: nextCursor,
        isFromCache: isFromCache,
        refreshError: null,
      ),
    );

    final result = await _getPostListSliceUseCase(
      GetPostListSliceParams(
        limit: _pageSize,
        cursor: cursor,
      ),
    );

    result.fold(
      (failure) {
        emit(
          PostListSuccess(
            posts: existingPosts,
            nextCursor: nextCursor,
            isFromCache: isFromCache,
            refreshError: failure.message,
          ),
        );
      },
      (listSlice) {
        emit(
          PostListSuccess(
            posts: _mergePosts(
              existingPosts: existingPosts,
              listSlice: listSlice,
            ),
            nextCursor: listSlice.nextCursor,
            isFromCache: listSlice.source == PostListSource.cache,
            refreshError: listSlice.refreshFailure?.message,
          ),
        );
      },
    );
  }

  void _onInitialListSliceReceived(
    _InitialListSliceReceived event,
    Emitter<PostListState> emit,
  ) {
    event.result.fold(
      (failure) {
        if (state.posts.isEmpty) {
          emit(
            PostListFailure(
              error: failure.message,
              posts: state.posts,
              nextCursor: state.nextCursor,
              isFromCache: false,
              refreshError: null,
            ),
          );
          return;
        }

        emit(
          PostListSuccess(
            posts: state.posts,
            nextCursor: state.nextCursor,
            isFromCache: state.isFromCache,
            refreshError: failure.message,
          ),
        );
      },
      (listSlice) {
        emit(
          PostListSuccess(
            posts: listSlice.posts,
            nextCursor: listSlice.nextCursor,
            isFromCache: listSlice.source == PostListSource.cache,
            refreshError: listSlice.refreshFailure?.message,
          ),
        );
      },
    );
  }

  List<Post> _mergePosts({
    required List<Post> existingPosts,
    required PostListSlice listSlice,
  }) {
    return [
      ...existingPosts,
      ...listSlice.posts.where(
        (post) =>
            existingPosts.every((existingPost) => existingPost.id != post.id),
      ),
    ];
  }
}
