import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/helpers/base_use_case.dart';
import '../repositories/document_repository.dart';

class UploadDocumentsUseCase extends BaseUseCase<bool, Map<String, dynamic>> {
  final IDocumentRepository documentRepository;

  UploadDocumentsUseCase({required this.documentRepository});

  @override
  Future<Either<bool, Failure>> call(Map<String, dynamic> params) {
    return documentRepository.uploadDocuments(params);
  }
}
