import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/forward_message_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/forward_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';

class ForwardMessageUseCase
    extends BaseUseCase<ForwardMessageEntity, ForwardMessageParams> {
  final ISendMessageRepository repository;

  ForwardMessageUseCase({required this.repository});

  @override
  Future<Either<ForwardMessageEntity, Failure>> call(
      ForwardMessageParams params) async {
    return await repository.forwardMessage(params);
  }
}
