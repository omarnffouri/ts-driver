// import 'package:dartz/dartz.dart';

// import '../../../../core/data/error/failures.dart';
// import '../../data/models/message.dart';
// import '../usecases/get_chat_messages_usecase.dart';
// import '../usecases/send_text_message_usecase.dart';

import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/get_previous_messages_params.dart';

abstract class IConversationDetailsRepository {
  Future<Either<ConversationDetailsEntity, Failure>> getConversationDetails(
      String conversationId);

  Future<Either<List<ConversationMessageEntity>, Failure>> getPreviousMessages(
      GetPreviousMessagesParams params);
}
