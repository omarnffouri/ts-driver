import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/contact_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/create_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/params/create_conversation_params.dart';

import '../../../../core/data/error/failures.dart';

abstract class IConversationRepository {
  Future<Either<List<ConversationEntity>, Failure>> getAllConversations();
  Future<Either<List<ContactEntity>, Failure>> getAllContacts();
  Future<Either<CreateConversationEntity, Failure>> createNewConversation(
      CreateConversationParams params);
  Future<Either<List<GroupConversationEntity>, Failure>>
      getAllGroupConversations();
}
