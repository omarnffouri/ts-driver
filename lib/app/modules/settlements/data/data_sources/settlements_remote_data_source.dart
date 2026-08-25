import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/settlements/data/models/partner_driver_model.dart';
import 'package:ts_driver/app/modules/settlements/data/models/settlement_data_model.dart';
import 'package:ts_driver/app/modules/settlements/data/models/settlement_details_model.dart';
import 'package:ts_driver/app/modules/settlements/domain/params/settlments_params.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';
import '../../domain/params/update_partner_driver_permission_params.dart';
import '../models/partner_settlement_data_model.dart';
import '../models/partner_settlement_details_model.dart';

abstract class ISettlementsDataSource {
  // driver settlements
  Future<Either<BaseResponse<List<SettlementDataModel>>, Failure>>
      getAllSettlements(
    SettlementParams params,
  );
  // driver settlement details
  Future<Either<SettlementDetailsModel, Failure>> getSettlementDetails(
    String settlementId,
  );

  // partner settlements
  Future<Either<List<PartnerSettlement>, Failure>> getAllParterSettlements(
    SettlementParams params,
  );

  // partner settlement details
  Future<Either<PartnerSettlementDetailsModel, Failure>>
      getPartnerSettlementDetails(
    String params,
  );
  // partner settlement drivers
  Future<Either<List<PartnerDriverModel>, Failure>> getPartnerDrivers();

  // update partner settlement drivers permission
  Future<Either<bool, Failure>> updatePartnerDriverState(
      UpdatePartnerDriverStateParams params);
}

class SettlementsRemoteDataSourceImpl implements ISettlementsDataSource {
  final DioClient client;

  SettlementsRemoteDataSourceImpl({required this.client});
  @override
  Future<Either<BaseResponse<List<SettlementDataModel>>, Failure>>
      getAllSettlements(SettlementParams params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getSettelments,
        method: RequestType.POST,
        data: params.toJson(),
        converter: (response) {
          try {
            return BaseResponse<List<SettlementDataModel>>.fromJson(
              response,
              (p0) =>
                  (p0 as List?)
                      ?.map((e) => SettlementDataModel.fromJson(e))
                      .toList() ??
                  <SettlementDataModel>[],
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
  Future<Either<SettlementDetailsModel, Failure>> getSettlementDetails(
      String settlementId) async {
    try {
      final response = await client.makeRequest(
        url: '${ApiConstants.getSettelmentDetails}/$settlementId/detail',
        method: RequestType.GET,
        converter: (response) {
          try {
            return SettlementDetailsModel.fromJson(response['data']);
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
  Future<Either<List<PartnerSettlement>, Failure>> getAllParterSettlements(
      SettlementParams params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getPartnerSettlements,
        method: RequestType.POST,
        data: params.toJson(),
        converter: (response) {
          try {
            if (response['data'] == null) {
              return <PartnerSettlement>[];
            }
            return (response['data'] as List)
                .map((e) => PartnerSettlement.fromJson(e))
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
  Future<Either<PartnerSettlementDetailsModel, Failure>>
      getPartnerSettlementDetails(String settlementId) async {
    try {
      final response = await client.makeRequest(
        url: '${ApiConstants.getPartnerSettlementDetails}/$settlementId/detail',
        method: RequestType.GET,
        converter: (response) {
          try {
            return PartnerSettlementDetailsModel.fromJson(response['data']);
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
  Future<Either<List<PartnerDriverModel>, Failure>> getPartnerDrivers() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getPartnerDrivers,
        method: RequestType.GET,
        converter: (response) {
          try {
            if (response['data'] == null) {
              return <PartnerDriverModel>[];
            }
            return (response['data'] as List)
                .map((e) => PartnerDriverModel.fromJson(e))
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
  Future<Either<bool, Failure>> updatePartnerDriverState(
      UpdatePartnerDriverStateParams params) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateDriverPermission,
        method: RequestType.PUT,
        data: params,
        converter: (response) {
          try {
            return true;
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
