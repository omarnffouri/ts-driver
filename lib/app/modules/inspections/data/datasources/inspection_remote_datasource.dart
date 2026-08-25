import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/enum/http_request_type.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../models/create_inspection_response.dart';
import '../models/inspection_options_model.dart';

abstract class IInspectionRemoteDataSource {
  Future<Either<InspectionOptionResponseModel, Failure>> getInspectionOptions(
    NoParams params,
  );
  Future<Either<CreateInspectionResponseModel, Failure>> createInspection(
    FormData params,
  );
}

class InspectionRemoteDataSourceImpl implements IInspectionRemoteDataSource {
  final DioClient client;
  InspectionRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<InspectionOptionResponseModel, Failure>> getInspectionOptions(
      NoParams params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getInspectionOptions,
        method: RequestType.GET,
        converter: (response) {
          try {
            return InspectionOptionResponseModel.fromJson(response);
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
  Future<Either<CreateInspectionResponseModel, Failure>> createInspection(
      FormData params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.createInspection,
        method: RequestType.POST,
        data: params,
        converter: (response) {
          try {
            return CreateInspectionResponseModel.fromJson(response);
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
