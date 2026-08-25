import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/shipments/domain/repositories/shipment_repository.dart';
import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/services/injection_service.dart';
import '../datasources/shipment_remote_datasource.dart';
import '../models/shipment_model.dart';

class ShipmentRepositoryImpl implements IShipmentRepository {
  IShipmentRemoteDataSource shipmentDataSource =
      sl<IShipmentRemoteDataSource>();
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  ShipmentRepositoryImpl({required this.shipmentDataSource});

  @override
  Future<Either<BaseResponse<List<ShipmentModel>>, Failure>> getAllShipments(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        return await shipmentDataSource.getAllShipments(params);
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<ShipmentModel, Failure>> getShipmentDetails(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        return await shipmentDataSource.getShipmentDetails(params);
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<ShipmentModel, Failure>> updateShipment(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        return await shipmentDataSource.updateShipment(params);
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<ShipmentModel, Failure>> completeShipment(
      FormData params) async {
    if (await networkInfo.isConnected) {
      try {
        return await shipmentDataSource.completeShipment(params);
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> stopReached(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        return await shipmentDataSource.stopReached(params);
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }
}
