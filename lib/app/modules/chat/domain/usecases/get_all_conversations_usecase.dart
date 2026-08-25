import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/repositories/conversation_repository.dart';

import '../../../../core/helpers/base_use_case.dart';

class GetAllConversationsUseCase
    extends BaseUseCase<List<ConversationEntity>, NoParams> {
  final IConversationRepository conversationRepository;

  GetAllConversationsUseCase({required this.conversationRepository});

  @override
  Future<Either<List<ConversationEntity>, Failure>> call(
      NoParams params) async {
    return await conversationRepository.getAllConversations();
  }
}
