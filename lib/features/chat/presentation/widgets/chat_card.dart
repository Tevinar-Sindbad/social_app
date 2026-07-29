import 'package:flutter/material.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/presentation/formatting/format_chat_title.dart';

/// A chat card widget that displays a summary of a chat session in the chats
/// page.
class ChatCard extends StatelessWidget {
  /// Creates a [ChatCard].
  const ChatCard({
    required this.chat,
    required this.currentUserId,
    super.key,
  });

  /// The chat.
  final Chat chat;

  /// Authenticated app user id used to hide the current user from the label.
  final String currentUserId;

  /// Computes the display name list without the current signed-in user.
  String computeChatMembersNames() {
    return formatChatTitleFromMembers(
      chat.members,
      currentUserId: currentUserId,
      fallback: '',
    );
  }

  /// Formats the last-message preview shown in the chat list row.
  String computeLastMessagePreview() {
    final lastMessage = chat.lastMessage;

    if (lastMessage == null) {
      return 'No messages yet';
    }

    final author = lastMessage.author;

    if (author?.id == currentUserId) {
      return 'You: ${lastMessage.content}';
    }

    if (chat.members.length > 2 && author != null) {
      return '${author.name}: ${lastMessage.content}';
    }

    return lastMessage.content;
  }

  @override
  /// The build.
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final lastMessageTimestamp = lastMessage?.createdAt;
    final lastMessagePreview = computeLastMessagePreview();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await ChatMessagesPageRoute(
            chatId: chat.id,
            initialTitle: computeChatMembersNames(),
          ).push<void>(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            spacing: 10,
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            computeChatMembersNames(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          () {
                            if (lastMessageTimestamp == null) {
                              return '';
                            } else {
                              return isSameDay(
                                    lastMessageTimestamp,
                                    DateTime.now(),
                                  )
                                  ? formatToHour(lastMessageTimestamp)
                                  : formatToDay(lastMessageTimestamp);
                            }
                          }(),
                        ),
                      ],
                    ),
                    Text(
                      lastMessagePreview,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppPallete.darkForegroundColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
