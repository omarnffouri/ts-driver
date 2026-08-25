import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/send_message_repository.dart';

class DeleteMessageUseCase extends BaseUseCase<BaseResponse<bool>, int> {
  final ISendMessageRepository repository;

  DeleteMessageUseCase({required this.repository});

  @override
  Future<Either<BaseResponse<bool>, Failure>> call(int params) async {
    return await repository.deleteMessage(params);
  }
}
