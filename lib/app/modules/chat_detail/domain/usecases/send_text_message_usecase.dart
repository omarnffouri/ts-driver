import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_sent_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_text_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class SendTextMessageUseCase
    extends BaseUseCase<MessageSentEntity, SendTextMessageParams> {
  final ISendMessageRepository sendMessageRepository;

  SendTextMessageUseCase({required this.sendMessageRepository});

  @override
  Future<Either<MessageSentEntity, Failure>> call(
      SendTextMessageParams params) async {
    return await sendMessageRepository.sendTextMessage(params);
  }
}
