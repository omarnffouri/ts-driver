import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../models/trailer_model.dart';
import '../models/truck_model.dart';

abstract class IVehicleDocumentsRemoteDataSource {
  Future<Either<List<TruckModel>, Failure>> getAllTruckDocuments();
  Future<Either<List<TrailerModel>, Failure>> getAllTrailerDocuments();
}

class VehicleDocumentsRemoteDataSourceImpl
    implements IVehicleDocumentsRemoteDataSource {
  final DioClient client;
  VehicleDocumentsRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<List<TruckModel>, Failure>> getAllTruckDocuments() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getTruckDocuments,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => TruckModel.fromJson(e as Map<String, dynamic>))
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
  Future<Either<List<TrailerModel>, Failure>> getAllTrailerDocuments() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getTrailerDocuments,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => TrailerModel.fromJson(e as Map<String, dynamic>))
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
}
