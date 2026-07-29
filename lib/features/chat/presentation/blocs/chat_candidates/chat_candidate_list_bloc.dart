import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidate_list_slice.dart';
import 'package:social_app/features/chat/domain/use_cases/chat_candidate/get_chat_candidate_list_slice_use_case.dart';

part 'chat_candidate_list_event.dart';
part 'chat_candidate_list_state.dart';

/// BLoC responsible for displaying a paginated list of chat candidates.
class ChatCandidateListBloc
    extends Bloc<ChatCandidateListEvent, ChatCandidateListState> {
  /// Creates a [ChatCandidateListBloc].
  ChatCandidateListBloc({
    required GetChatCandidateListSliceUseCase getChatCandidateListSlice,
  }) : _getChatCandidateListSlice = getChatCandidateListSlice,
       super(
         const ChatCandidateListLoading(
           candidates: [],
           nextCursor: null,
         ),
       ) {
    on<LoadChatCandidateListNextSlice>(
      _onLoadChatCandidateListNextSlice,
      transformer: droppable(),
    );
    add(const LoadChatCandidateListNextSlice());
  }

  static const int _pageSize = 20;

  final GetChatCandidateListSliceUseCase _getChatCandidateListSlice;

  Future<void> _onLoadChatCandidateListNextSlice(
    LoadChatCandidateListNextSlice event,
    Emitter<ChatCandidateListState> emit,
  ) async {
    // Stop pagination once the backend has no next cursor for additional data.
    if (state.candidates.isNotEmpty && state.nextCursor == null) {
      return;
    }

    final previousCandidates = state.candidates;
    final previousCursor = state.nextCursor;

    emit(
      ChatCandidateListLoading(
        candidates: previousCandidates,
        nextCursor: previousCursor,
      ),
    );

    final result = await _getChatCandidateListSlice(
      GetChatCandidateListSliceParams(
        limit: _pageSize,
        cursor: previousCursor,
      ),
    );

    result.fold(
      (error) {
        emit(
          ChatCandidateListFailure(
            error: error.message,
            candidates: previousCandidates,
            nextCursor: previousCursor,
          ),
        );
      },
      (candidateSlice) {
        emit(
          ChatCandidateListSuccess(
            candidates: _mergeCandidates(
              existingCandidates: previousCandidates,
              candidateSlice: candidateSlice,
            ),
            nextCursor: candidateSlice.nextCursor,
          ),
        );
      },
    );
  }

  List<ChatUserSummary> _mergeCandidates({
    required List<ChatUserSummary> existingCandidates,
    required ChatCandidateListSlice candidateSlice,
  }) {
    return [
      ...existingCandidates,
      ...candidateSlice.candidates.where(
        (candidate) => existingCandidates.every(
          (existingCandidate) => existingCandidate.id != candidate.id,
        ),
      ),
    ];
  }
}
