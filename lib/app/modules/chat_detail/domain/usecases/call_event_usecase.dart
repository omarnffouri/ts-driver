import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/call_event_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/call_event_param.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';

class CallEventUsecase extends BaseUseCase<CallEventEntity, CallEventParam> {
  final ISendMessageRepository repository;

  CallEventUsecase({required this.repository});

  @override
  Future<Either<CallEventEntity, Failure>> call(CallEventParam params) async {
    return await repository.emitEvent(params);
  }
}
