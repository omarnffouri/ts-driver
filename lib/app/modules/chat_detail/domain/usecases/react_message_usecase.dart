import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/react_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/repositories/send_message_repository.dart';

class ReactMessageUseCase
    extends BaseUseCase<BaseResponse<bool>, ReactMessageParams> {
  final ISendMessageRepository repository;

  ReactMessageUseCase({required this.repository});

  @override
  Future<Either<BaseResponse<bool>, Failure>> call(
      ReactMessageParams params) async {
    return await repository.reactOnMessage(params);
  }
}
