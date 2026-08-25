import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/contact_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/repositories/conversation_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class GetAllContactsUserCase
    extends BaseUseCase<List<ContactEntity>, NoParams> {
  final IConversationRepository conversationRepository;

  GetAllContactsUserCase({required this.conversationRepository});

  @override
  Future<Either<List<ContactEntity>, Failure>> call(NoParams params) async {
    return await conversationRepository.getAllContacts();
  }
}
