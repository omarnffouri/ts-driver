import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/documents/domain/repositories/document_repository.dart';

import '../../../../core/helpers/base_use_case.dart';
import '../entities/document_entity.dart';

class GetAllDocumentsUseCase
    extends BaseUseCase<List<DocumentEntity>, NoParams> {
  final IDocumentRepository documentRepository;

  GetAllDocumentsUseCase({required this.documentRepository});

  @override
  Future<Either<List<DocumentEntity>, Failure>> call(NoParams params) async {
    return await documentRepository.getAllDocuments();
  }
}
