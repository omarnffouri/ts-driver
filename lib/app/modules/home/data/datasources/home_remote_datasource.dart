import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/enum/http_request_type.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/home/data/models/applicant_state.dart';
import 'package:ts_driver/app/modules/home/data/models/check_clock_in_model.dart';
import '../../../../core/data/connection/api_constants.dart';
import '../../../../core/data/connection/dio_client.dart';

abstract class IHomeRemoteDatasource {
  Future<Either<ApplicantState, Failure>> getApplicationState();
  Future<Either<CheckClockInDataModel, Failure>> checkClockIn();
  Future<Either<BaseResponse<bool>, Failure>> clockIn();
  Future<Either<BaseResponse<bool>, Failure>> clockOut();
  Future<Either<bool, Failure>> updateVoipToken(String params);
}

class HomeRemoteDatasourceImpl implements IHomeRemoteDatasource {
  final DioClient client;

  HomeRemoteDatasourceImpl({required this.client});
  @override
  Future<Either<ApplicantState, Failure>> getApplicationState() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.applicantState,
        isIsolate: false,
        converter: (response) {
          try {
            return ApplicantState.fromJson(
                response['data']['data'] as Map<String, dynamic>);
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
  Future<Either<CheckClockInDataModel, Failure>> checkClockIn() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.checkClockIn,
        isIsolate: false,
        converter: (response) {
          try {
            return CheckClockInDataModel.fromJson(
                response['data'] as Map<String, dynamic>);
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
  Future<Either<BaseResponse<bool>, Failure>> clockIn() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.clockIn,
        method: RequestType.GET,
        converter: (response) {
          try {
            return BaseResponse.fromJson(
              response,
              (p0) => response['code'] == 200,
            );
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
  Future<Either<BaseResponse<bool>, Failure>> clockOut() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.clockOut,
        method: RequestType.GET,
        converter: (response) {
          try {
            return BaseResponse.fromJson(
              response,
              (p0) => response['code'] == 200,
            );
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
  Future<Either<bool, Failure>> updateVoipToken(String params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateVoip,
        data: {
          "voip_token": params,
        },
        method: RequestType.POST,
        converter: (response) {
          final data = BaseResponse.fromJson(response, (json) {
            return null;
          });
          return data.code == 200;
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
