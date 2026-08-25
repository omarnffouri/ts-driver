import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/modules/forms/data/models/signed_form_model.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';
import '../../../../core/values/constants.dart';
import '../models/form_model.dart';

abstract class IFormRemoteDataSource {
  Future<Either<List<FormModel>, Failure>> getAllForms();
  Future<Either<List<SignedFormModel>, Failure>> getAllSignedForms();
  Future<Either<bool, Failure>> signForm(MapBody body);
  Future<Either<bool, Failure>> updateAttachmentStatus(MapBody body);
}

class FormRemoteDataSourceImpl implements IFormRemoteDataSource {
  final DioClient client;
  FormRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<List<FormModel>, Failure>> getAllForms() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getForms,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => FormModel.fromJson(e))
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
  Future<Either<List<SignedFormModel>, Failure>> getAllSignedForms() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getSignedForm,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => SignedFormModel.fromJson(e))
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
  Future<Either<bool, Failure>> signForm(MapBody body) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.PUT,
        url: ApiConstants.signForm,
        data: body,
        converter: (response) {
          try {
            return (response['data']['code'] == 200);
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
  Future<Either<bool, Failure>> updateAttachmentStatus(MapBody body) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.PUT,
        url: ApiConstants.updateFormAttachmentStatus,
        data: body,
        converter: (response) {
          try {
            return (response['data']['status'] == 200);
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
