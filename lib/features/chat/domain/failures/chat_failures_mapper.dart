import 'package:social_app/core/errors/failures/failure_messages.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/failures/remote_data_source_exceptions_to_failures_mapper.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/features/chat/domain/failures/chat_failure_messages.dart';

/// Maps chat-owned exceptions and backend error codes into [Failure]s.
Failure mapChatExceptionToFailure(Object error) {
  if (error is RemoteServerException) {
    switch (error.code) {
      case 'invalid_chat_member_id':
      case 'invalid_chat_members':
        return const ValidationFailure(ChatFailureMessages.invalidMembers);

      case 'invalid_chat_message_content':
        return const ValidationFailure(
          ChatFailureMessages.invalidMessageContent,
        );

      case 'invalid_chat_candidate_cursor':
      case 'invalid_chat_list_cursor':
      case 'invalid_chat_message_cursor':
        return const ValidationFailure(CommonFailureMessages.invalidCursor);

      case 'chat_member_not_found':
      case 'chat_not_found':
        return const NotFoundFailure();
    }
  }

  return mapRemoteDataSourceExceptionToFailure(error);
}
