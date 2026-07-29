part of 'chat_session_bloc.dart';

@immutable
/// Base type for all chat-session events.
sealed class ChatSessionEvent {}

/// Requests resolving an existing chat or starting a new one.
class AddChat extends ChatSessionEvent {
  /// Creates an [AddChat].
  AddChat({required this.chatMembers});

  /// Members to include in the new chat
  final List<ChatUserSummary> chatMembers;
}

/// Requests creation of the first message for a new chat session.
class AddChatFirstMessage extends ChatSessionEvent {
  /// Creates an [AddChatFirstMessage].
  AddChatFirstMessage({required this.firstMessageContent});

  /// Content of the first message to send.
  final String firstMessageContent;
}

/// Resolves an existing chat session by its stable identifier.
class OpenChatById extends ChatSessionEvent {
  /// Creates an [OpenChatById].
  OpenChatById({required this.chatId});

  /// Identifier of the target chat session.
  final String chatId;
}
