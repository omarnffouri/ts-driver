import 'package:dartz/dartz.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';
import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/vehicle_documents_repository.dart';
import '../datasources/vehicle_documents_local_datasource.dart';
import '../datasources/vehicle_documents_remote_datasource.dart';
import '../models/trailer_model.dart';
import '../models/truck_model.dart';

class VehicleDocumentsRepositoryImpl implements IVehicleDocumentsRepository {
  IVehicleDocumentsRemoteDataSource truckRemoteDataSource;
  IVehicleDocumentsLocalDataSource truckLocalDataSource;
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  VehicleDocumentsRepositoryImpl({
    required this.truckRemoteDataSource,
    required this.truckLocalDataSource,
  });

  @override
  Future<Either<List<TruckModel>, Failure>> getAllTruckDocuments() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await truckRemoteDataSource.getAllTruckDocuments();
        return response.fold(
          (List<TruckModel> trucks) async {
            await truckLocalDataSource.cacheTruckDocuments(trucks);
            return Left(trucks);
          },
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      try {
        return await truckLocalDataSource.getAllTruckDocuments();
      } on EmptyCacheException {
        return const Right(
          EmptyCacheFailure(message: 'No data found , try again later'),
        );
      }
    }
  }

  @override
  Future<Either<List<TrailerModel>, Failure>> getAllTrailerDocuments() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await truckRemoteDataSource.getAllTrailerDocuments();
        return response.fold(
          (List<TrailerModel> trailers) async {
            await truckLocalDataSource.cacheTrailerDocuments(trailers);
            return Left(trailers);
          },
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      try {
        return await truckLocalDataSource.getAllTrailerDocuments();
      } on EmptyCacheException {
        return const Right(
          EmptyCacheFailure(message: 'No data found , try again later'),
        );
      }
    }
  }
}
