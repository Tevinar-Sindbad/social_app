import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Reads one existing chat by its stable identifier.
class GetChatByIdUseCase implements UseCase<Chat, GetChatByIdParams> {
  /// Creates a [GetChatByIdUseCase].
  GetChatByIdUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to fetch one chat by its identifier.
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, Chat>> call(GetChatByIdParams params) {
    return _chatRepository.getChatById(chatId: params.chatId);
  }
}

/// Parameters required to read one chat by id.
class GetChatByIdParams {
  /// Creates a [GetChatByIdParams].
  const GetChatByIdParams({
    required this.chatId,
  });

  /// Stable identifier of the target chat.
  final String chatId;
}
