import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/send_files_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_sent_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';

import '../../../../core/helpers/base_use_case.dart';

class SendFileMessageUseCase
    extends BaseUseCase<MessageSentEntity, SendFilesMessageParams> {
  final ISendMessageRepository sendMessageRepository;

  SendFileMessageUseCase({required this.sendMessageRepository});

  @override
  Future<Either<MessageSentEntity, Failure>> call(
      SendFilesMessageParams params) async {
    return await sendMessageRepository.sendFileMessage(params);
  }
}
