import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/get_previous_messages_params.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/conversation_details_repository.dart';

class GetPreviousMessagesUseCase extends BaseUseCase<
    List<ConversationMessageEntity>, GetPreviousMessagesParams> {
  final IConversationDetailsRepository _repository;

  GetPreviousMessagesUseCase(this._repository);

  @override
  Future<Either<List<ConversationMessageEntity>, Failure>> call(
      GetPreviousMessagesParams params) async {
    return _repository.getPreviousMessages(params);
  }
}
