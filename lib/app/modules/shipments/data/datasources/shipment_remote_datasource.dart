import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/enum/http_request_type.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/shipments/data/models/shipment_model.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';
import 'package:dio/dio.dart';

abstract class IShipmentRemoteDataSource {
  Future<Either<BaseResponse<List<ShipmentModel>>, Failure>> getAllShipments(
      MapBody params);
  Future<Either<ShipmentModel, Failure>> getShipmentDetails(MapBody params);
  Future<Either<ShipmentModel, Failure>> updateShipment(MapBody params);
  Future<Either<ShipmentModel, Failure>> completeShipment(FormData params);
  Future<Either<bool, Failure>> stopReached(MapBody params);
}

class ShipmentRemoteDataSourceImpl implements IShipmentRemoteDataSource {
  final DioClient client;
  ShipmentRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<BaseResponse<List<ShipmentModel>>, Failure>> getAllShipments(
      MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getShipments,
        data: body,
        converter: (response) {
          try {
            final hasMore = response['data']['has_more'] as bool;
            final data = response['data']['data'] as List;
            final shipments =
                data.map((e) => ShipmentModel.fromJson(e)).toList();
            return BaseResponse(
              data: shipments,
              hasMore: hasMore,
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
  Future<Either<ShipmentModel, Failure>> getShipmentDetails(
      MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getShipmentDetails,
        data: body,
        converter: (response) {
          try {
            return ShipmentModel.fromJson(response['data']['data']);
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
  Future<Either<ShipmentModel, Failure>> updateShipment(MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateShipment,
        data: body,
        method: RequestType.PUT,
        converter: (response) {
          try {
            return ShipmentModel.fromJson(response['data']['data']);
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
  Future<Either<ShipmentModel, Failure>> completeShipment(FormData body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.completeShipment,
        data: body,
        method: RequestType.POST,
        converter: (response) {
          try {
            return ShipmentModel.fromJson(response['data']['data']);
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
  Future<Either<bool, Failure>> stopReached(MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.stopReached,
        data: body,
        method: RequestType.POST,
        converter: (response) {
          try {
            return (response['data']['data'] != null);
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
