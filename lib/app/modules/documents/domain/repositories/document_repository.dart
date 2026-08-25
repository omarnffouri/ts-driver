import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/documents/domain/entities/document_entity.dart';

import '../../../../core/data/error/failures.dart';

abstract class IDocumentRepository {
  Future<Either<List<DocumentEntity>, Failure>> getAllDocuments();
  Future<Either<bool, Failure>> uploadDocuments(Map<String, dynamic> params);
}
