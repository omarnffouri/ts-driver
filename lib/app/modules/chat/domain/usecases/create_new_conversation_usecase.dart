import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/create_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/params/create_conversation_params.dart';
import 'package:ts_driver/app/modules/chat/domain/repositories/conversation_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class CreateNewConversationUserCase
    extends BaseUseCase<CreateConversationEntity, CreateConversationParams> {
  final IConversationRepository conversationRepository;

  CreateNewConversationUserCase({required this.conversationRepository});

  @override
  Future<Either<CreateConversationEntity, Failure>> call(
      CreateConversationParams params) async {
    return await conversationRepository.createNewConversation(params);
  }
}
