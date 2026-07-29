import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/domain/use_cases/chat/create_chat_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/chat/get_chat_by_id_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/chat/get_chat_by_members_use_case.dart';

part 'chat_session_event.dart';
part 'chat_session_state.dart';

/// Bloc handling the chat session flow (selection, creation)
class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  /// Creates a [ChatSessionBloc].
  ChatSessionBloc({
    required CreateChatUseCase createChat,
    required GetChatByMembersUseCase getChatByMembers,
    required GetChatByIdUseCase getChatById,
  }) : _createChat = createChat,
       _getChatByMembers = getChatByMembers,
       _getChatById = getChatById,
       super(const ChatSessionDrafted(chatMembers: [])) {
    on<AddChat>(_onAddChat);
    on<AddChatFirstMessage>(_onAddChatFirstMessage);
    on<OpenChatById>(_onOpenChatById);
  }
  final CreateChatUseCase _createChat;
  final GetChatByMembersUseCase _getChatByMembers;
  final GetChatByIdUseCase _getChatById;

  /// When no chat exists yet, wait for the first backend message.
  /// If one already exists, navigate directly to the chat page.
  Future<void> _onAddChat(AddChat event, Emitter<ChatSessionState> emit) async {
    emit(ChatSessionLoading(chatMembers: event.chatMembers));
    final res = await _getChatByMembers.call(
      GetChatByMembersParams(
        memberIds: event.chatMembers.map((m) => m.id).toList(),
      ),
    );

    res.fold(
      (failure) => emit(
        ChatSessionFailure(failure.message, chatMembers: state.chatMembers),
      ),
      (chat) {
        if (chat == null) {
          emit(
            ChatSessionWaitingForFirstMessage(chatMembers: state.chatMembers),
          );
        } else {
          emit(
            ChatSessionLoaded(chatId: chat.id, chatMembers: chat.members),
          );
        }
      },
    );
  }

  /// On first message addition, add chat to backend with the first message
  Future<void> _onAddChatFirstMessage(
    AddChatFirstMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionLoading(chatMembers: state.chatMembers));

    final res = await _createChat.call(
      CreateChatParams(
        memberIds: state.chatMembers.map((m) => m.id).toList(),
        firstMessageContent: event.firstMessageContent,
      ),
    );

    res.fold(
      (failure) => emit(
        ChatSessionFailure(failure.message, chatMembers: state.chatMembers),
      ),
      (chatWriteResult) => emit(
        ChatSessionLoaded(
          chatId: chatWriteResult.chat.id,
          chatMembers: chatWriteResult.chat.members,
        ),
      ),
    );
  }

  Future<void> _onOpenChatById(
    OpenChatById event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionLoading(chatMembers: state.chatMembers));

    final res = await _getChatById.call(
      GetChatByIdParams(chatId: event.chatId),
    );

    res.fold(
      (failure) => emit(
        ChatSessionFailure(failure.message, chatMembers: state.chatMembers),
      ),
      (chat) => emit(
        ChatSessionLoaded(chatId: chat.id, chatMembers: chat.members),
      ),
    );
  }
}
