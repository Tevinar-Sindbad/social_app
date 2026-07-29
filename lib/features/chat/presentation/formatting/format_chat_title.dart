import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Formats a chat title from chat members.
///
/// When [currentUserId] is provided, that member is excluded from the title.
/// Remaining names are normalized for presentation by dropping blank values,
/// sorting them case-insensitively, and joining them with commas. When the
/// resulting label is empty, [fallback] is returned instead.
String formatChatTitleFromMembers(
  Iterable<ChatUserSummary> members, {
  String? currentUserId,
  String fallback = 'Chat',
}) {
  final title =
      members
          .where((member) => member.id != currentUserId)
          .map((member) => member.name.trim())
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  final joinedTitle = title.join(', ');

  return joinedTitle.isEmpty ? fallback : joinedTitle;
}
