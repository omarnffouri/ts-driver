import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';
import '../entities/shipment_entity.dart';

abstract class IShipmentRepository {
  Future<Either<BaseResponse<List<ShipmentEntity>>, Failure>> getAllShipments(
      MapBody params);
  Future<Either<ShipmentEntity, Failure>> getShipmentDetails(MapBody params);
  Future<Either<ShipmentEntity, Failure>> updateShipment(MapBody params);
  Future<Either<ShipmentEntity, Failure>> completeShipment(FormData params);
  Future<Either<bool, Failure>> stopReached(MapBody params);
}
