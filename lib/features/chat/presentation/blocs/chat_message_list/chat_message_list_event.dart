part of 'chat_message_list_bloc.dart';

@immutable
/// Represents chat message list events.
sealed class ChatMessagesEvent {
  const ChatMessagesEvent();
}

/// Creates one new message in the current chat.
class AddChatMessage extends ChatMessagesEvent {
  /// Creates an [AddChatMessage].
  const AddChatMessage({
    required this.chatId,
    required this.content,
    required this.author,
  });

  /// Identifier of the chat that should receive the new message.
  final String chatId;

  /// Message content to send.
  final String content;

  /// Current user, used for the optimistic ui message.
  final ChatUserSummary author;
}

/// Bootstraps the first message slice for the current chat.
class _LoadInitialChatMessageListSlice extends ChatMessagesEvent {
  /// Creates a [_LoadInitialChatMessageListSlice].
  const _LoadInitialChatMessageListSlice();
}

/// Loads the next cursor-based message slice.
class LoadChatMessageListNextSlice extends ChatMessagesEvent {
  /// Creates a [LoadChatMessageListNextSlice].
  const LoadChatMessageListNextSlice();
}

/// Applies one live chat-message change received from the backend.
final class _ChatMessageListChangeReceived extends ChatMessagesEvent {
  /// Creates a [_ChatMessageListChangeReceived].
  const _ChatMessageListChangeReceived(this.chatMessageChange);

  /// The chat-message change payload.
  final Either<Failure, ChatMessageListChange> chatMessageChange;
}
