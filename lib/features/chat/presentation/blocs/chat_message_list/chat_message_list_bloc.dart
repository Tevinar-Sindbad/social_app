import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';
import 'package:social_app/features/chat/domain/use_cases/chat_message/create_chat_message_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/chat_message/get_chat_message_list_slice_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/chat_message/subscribe_to_chat_message_list_use_case.dart';

part 'chat_message_list_event.dart';
part 'chat_message_list_state.dart';

/// Manages the chat-message list state for one chat.
class ChatMessageListBloc
    extends Bloc<ChatMessagesEvent, ChatMessageListState> {
  /// Creates a [ChatMessageListBloc].
  ChatMessageListBloc({
    required String chatId,
    required GetChatMessageListSliceUseCase getChatMessageListSlice,
    required SubscribeToChatMessageListUseCase subscribeToChatMessageList,
    required CreateChatMessageUseCase createChatMessage,
  }) : _chatId = chatId,
       _getChatMessageListSlice = getChatMessageListSlice,
       _subscribeToChatMessageList = subscribeToChatMessageList,
       _createChatMessage = createChatMessage,
       super(
         ChatMessageListLoading(
           chatId: chatId,
           chatMessages: const [],
           nextCursor: null,
         ),
       ) {
    on<LoadChatMessageListNextSlice>(
      _onLoadChatMessagesNextPage,
      transformer: droppable(),
    );
    on<_ChatMessageListChangeReceived>(_onChatMessageChangeReceived);
    on<_LoadInitialChatMessageListSlice>(_onLoadInitialChatMessagesPage);
    on<AddChatMessage>(_onAddChatMessage);
    add(const _LoadInitialChatMessageListSlice());
  }

  static const int _pageSize = 20;
  static const String _optimisticMessageIdPrefix = 'optimistic-message:';

  final String _chatId;
  final GetChatMessageListSliceUseCase _getChatMessageListSlice;
  final SubscribeToChatMessageListUseCase _subscribeToChatMessageList;
  final CreateChatMessageUseCase _createChatMessage;

  StreamSubscription<Either<Failure, ChatMessageListChange>>?
  _chatMessageChangeSub;

  @override
  Future<void> close() async {
    await _chatMessageChangeSub?.cancel();
    await super.close();
  }

  /// Starts listening to realtime message changes for the active chat.
  Future<void> _addListenerToSubscription() async {
    // Cancel previous subscription if exists. This is important to avoid
    // creating multiple subscriptions if the bloc is ever reinitialized.
    await _chatMessageChangeSub?.cancel();
    _chatMessageChangeSub =
        _subscribeToChatMessageList(
          SubscribeToChatMessageListParams(chatId: _chatId),
        ).listen((event) {
          add(_ChatMessageListChangeReceived(event));
        });
  }

  /// Starts realtime sync and kicks off the first page load.
  Future<void> _onLoadInitialChatMessagesPage(
    _LoadInitialChatMessageListSlice event,
    Emitter<ChatMessageListState> emit,
  ) async {
    await _addListenerToSubscription();

    add(const LoadChatMessageListNextSlice());
  }

  /// Optimistically inserts the new message before sending it to the backend.
  Future<void> _onAddChatMessage(
    AddChatMessage event,
    Emitter<ChatMessageListState> emit,
  ) async {
    final optimisticChatMessage = _buildOptimisticChatMessage(event);

    emit(
      state.copyWith(
        chatId: event.chatId,
        chatMessages: [
          ...state.chatMessages,
          optimisticChatMessage,
        ],
      ),
    );

    final result = await _createChatMessage(
      CreateChatMessageParams(chatId: event.chatId, content: event.content),
    );

    result.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: state.chatId,
            error: failure.message,
            chatMessages: _removeChatMessageById(optimisticChatMessage.id),
            nextCursor: state.nextCursor,
          ),
        );
      },
      (chatWriteResult) {
        final updatedMessages = _replaceOptimisticChatMessage(
          optimisticMessageId: optimisticChatMessage.id,
          confirmedChatMessage: chatWriteResult.chatMessage,
        );

        if (identical(updatedMessages, state.chatMessages)) {
          return;
        }

        emit(
          state.copyWith(
            chatMessages: updatedMessages,
          ),
        );
      },
    );
  }

  /// Applies realtime message inserts and surfaces stream failures.
  void _onChatMessageChangeReceived(
    _ChatMessageListChangeReceived event,
    Emitter<ChatMessageListState> emit,
  ) {
    event.chatMessageChange.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: state.chatId,
            error: failure.message,
            chatMessages: state.chatMessages,
            nextCursor: state.nextCursor,
          ),
        );
      },
      (chatMessageChange) {
        switch (chatMessageChange) {
          case ChatMessageInserted(:final chatId, :final chatMessage):
            if (chatId != state.chatId) {
              return;
            }

            final updatedMessages = _upsertIncomingChatMessage(chatMessage);

            if (identical(updatedMessages, state.chatMessages)) {
              return;
            }

            emit(
              state.copyWith(
                chatMessages: updatedMessages,
                nextCursor: state.nextCursor,
              ),
            );
        }
      },
    );
  }

  /// Loads the next cursor-based page while preserving the current items.
  Future<void> _onLoadChatMessagesNextPage(
    LoadChatMessageListNextSlice event,
    Emitter<ChatMessageListState> emit,
  ) async {
    if (state is! ChatMessageListLoading &&
        state.chatMessages.isNotEmpty &&
        state.nextCursor == null) {
      return;
    }

    final previousChatId = state.chatId;
    final previousMessages = state.chatMessages;
    final previousCursor = state.nextCursor;

    emit(
      ChatMessageListLoading(
        chatId: previousChatId,
        chatMessages: previousMessages,
        nextCursor: previousCursor,
      ),
    );

    final result = await _getChatMessageListSlice(
      GetChatMessageListSliceParams(
        chatId: previousChatId,
        limit: _pageSize,
        cursor: previousCursor,
      ),
    );

    final currentMessages = state.chatMessages;
    final currentCursor = state.nextCursor;

    result.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: previousChatId,
            error: failure.message,
            chatMessages: currentMessages,
            nextCursor: currentCursor,
          ),
        );
      },
      (chatMessageListSlice) {
        emit(
          ChatMessageListSuccess(
            chatId: previousChatId,
            chatMessages: _mergeChatMessages(
              existingMessages: currentMessages,
              chatMessageListSlice: chatMessageListSlice,
            ),
            nextCursor: chatMessageListSlice.nextCursor,
          ),
        );
      },
    );
  }

  /// Prepends one older fetched slice ahead of the already loaded messages.
  List<ChatMessage> _mergeChatMessages({
    required List<ChatMessage> existingMessages,
    required ChatMessageListSlice chatMessageListSlice,
  }) {
    final olderMessages = chatMessageListSlice.chatMessages.reversed.where(
      (nextMessage) => existingMessages.every(
        (existingMessage) => existingMessage.id != nextMessage.id,
      ),
    );

    return [
      ...olderMessages,
      ...existingMessages,
    ];
  }

  /// Builds a temporary local message used for optimistic rendering.
  ChatMessage _buildOptimisticChatMessage(AddChatMessage event) {
    final now = DateTime.now();

    return ChatMessage(
      id: '$_optimisticMessageIdPrefix${now.microsecondsSinceEpoch}',
      chatId: event.chatId,
      author: event.author,
      content: event.content,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Removes one message from the current state by its identifier.
  List<ChatMessage> _removeChatMessageById(String messageId) {
    return state.chatMessages
        .where((chatMessage) => chatMessage.id != messageId)
        .toList();
  }

  /// Replaces a temporary optimistic message with the confirmed backend one.
  List<ChatMessage> _replaceOptimisticChatMessage({
    required String optimisticMessageId,
    required ChatMessage confirmedChatMessage,
  }) {
    final optimisticMessageIndex = state.chatMessages.indexWhere(
      (chatMessage) => chatMessage.id == optimisticMessageId,
    );
    final confirmedMessageIndex = state.chatMessages.indexWhere(
      (chatMessage) => chatMessage.id == confirmedChatMessage.id,
    );

    if (confirmedMessageIndex != -1 && optimisticMessageIndex == -1) {
      return state.chatMessages;
    }

    if (confirmedMessageIndex != -1 && optimisticMessageIndex != -1) {
      return _removeChatMessageById(optimisticMessageId);
    }

    if (optimisticMessageIndex == -1) {
      return [
        ...state.chatMessages,
        confirmedChatMessage,
      ];
    }

    final updatedMessages = [...state.chatMessages];
    updatedMessages[optimisticMessageIndex] = confirmedChatMessage;

    return updatedMessages;
  }

  /// Inserts an incoming realtime message or swaps a matching optimistic one.
  List<ChatMessage> _upsertIncomingChatMessage(ChatMessage chatMessage) {
    if (state.chatMessages.any((message) => message.id == chatMessage.id)) {
      return state.chatMessages;
    }

    final matchingOptimisticMessageIndex = _findMatchingOptimisticMessageIndex(
      chatMessage,
    );

    if (matchingOptimisticMessageIndex == -1) {
      return [
        ...state.chatMessages,
        chatMessage,
      ];
    }

    final updatedMessages = [...state.chatMessages];
    updatedMessages[matchingOptimisticMessageIndex] = chatMessage;

    return updatedMessages;
  }

  /// Finds the optimistic message that best matches a confirmed message.
  int _findMatchingOptimisticMessageIndex(ChatMessage chatMessage) {
    for (var index = state.chatMessages.length - 1; index >= 0; index--) {
      if (_isMatchingOptimisticMessage(
        state.chatMessages[index],
        chatMessage,
      )) {
        return index;
      }
    }

    return -1;
  }

  /// Returns whether a local optimistic message matches a confirmed one.
  bool _isMatchingOptimisticMessage(
    ChatMessage existingMessage,
    ChatMessage confirmedChatMessage,
  ) {
    return existingMessage.id.startsWith(_optimisticMessageIdPrefix) &&
        existingMessage.chatId == confirmedChatMessage.chatId &&
        existingMessage.content == confirmedChatMessage.content &&
        existingMessage.author?.id == confirmedChatMessage.author?.id;
  }
}
