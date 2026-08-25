import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/data/connection/dio_client.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import '../../../../core/enum/http_request_type.dart';
import '../models/annoucement_model.dart';

abstract class IAnnoucementsRemoteDataSource {
  Future<Either<List<AnnoucementModel>, Failure>> getAllAnnoucements();
  Future<Either<bool, Failure>> updateAnnoucementReadStatus(int annoucementId);
}

class AnnoucementRemoteDataSourceImpl implements IAnnoucementsRemoteDataSource {
  final DioClient client;
  AnnoucementRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<List<AnnoucementModel>, Failure>> getAllAnnoucements() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getAllAnnoucements,
        converter: (response) {
          try {
            return (response['data'] as List)
                .map((e) => AnnoucementModel.fromJson(e))
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
  Future<Either<bool, Failure>> updateAnnoucementReadStatus(
      int annoucementId) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateAccoucementReadStatus,
        data: {"id": annoucementId},
        method: RequestType.PUT,
        converter: (response) {
          try {
            return response['code'] == 200;
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
}
