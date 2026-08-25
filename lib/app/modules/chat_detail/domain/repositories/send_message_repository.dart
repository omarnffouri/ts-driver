// import 'package:dartz/dartz.dart';

// import '../../../../core/data/error/failures.dart';
// import '../../data/models/message.dart';
// import '../usecases/get_chat_messages_usecase.dart';
// import '../usecases/send_text_message_usecase.dart';

import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/forward_message_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/call_event_param.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/forward_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/react_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_files_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_mark_as_read_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_sent_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_text_message_params.dart';

import '../entities/call_event_entity.dart';

abstract class ISendMessageRepository {
  Future<Either<MessageSentEntity, Failure>> sendTextMessage(
      SendTextMessageParams params);
  Future<Either<MessageSentEntity, Failure>> sendFileMessage(
      SendFilesMessageParams params);
  Future<Either<MessageMarkAsReadEntity, Failure>> markMessageAsRead(
      String messageId);
  Future<Either<ForwardMessageEntity, Failure>> forwardMessage(
      ForwardMessageParams params);
  Future<Either<BaseResponse<bool>, Failure>> reactOnMessage(
      ReactMessageParams params);
  Future<Either<BaseResponse<bool>, Failure>> deleteMessage(int params);
  Future<Either<CallEventEntity, Failure>> emitEvent(CallEventParam params);
}
