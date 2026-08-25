import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_mark_as_read_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';

import '../../../../core/helpers/base_use_case.dart';

class MessageMarkAsReadUseCase
    extends BaseUseCase<MessageMarkAsReadEntity, String> {
  final ISendMessageRepository sendMessageRepository;

  MessageMarkAsReadUseCase({required this.sendMessageRepository});

  @override
  Future<Either<MessageMarkAsReadEntity, Failure>> call(String params) async {
    return await sendMessageRepository.markMessageAsRead(params);
  }
}
