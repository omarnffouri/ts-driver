import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';
import '../models/document_model.dart';

abstract class IDocumentRemoteDataSource {
  Future<Either<List<DocumentModel>, Failure>> getAllDocuments();
  Future<Either<bool, Failure>> uploadDocuments(Map<String, dynamic> params);
}

class DocumentRemoteDataSourceImpl implements IDocumentRemoteDataSource {
  final DioClient client;

  DocumentRemoteDataSourceImpl({required this.client});
  @override
  Future<Either<List<DocumentModel>, Failure>> getAllDocuments() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getDocuments,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => DocumentModel.fromJson(e))
                .toList();
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> uploadDocuments(
      Map<String, dynamic> params) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.PUT,
        url: ApiConstants.uploadDocument,
        data: params,
        converter: (response) =>
            response['data']['data'] != null, //! apply this to register too
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
