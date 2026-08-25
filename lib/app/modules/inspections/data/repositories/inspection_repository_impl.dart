import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/entities/create_inspection_response_entity.dart';
import '../../domain/entities/inspection_options_entity.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../datasources/inspection_remote_datasource.dart';

class InspectionRepositoryImpl implements IInspectionRepository {
  IInspectionRemoteDataSource inspectionDataSource =
      sl<IInspectionRemoteDataSource>();
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  InspectionRepositoryImpl({required this.inspectionDataSource});

  @override
  Future<Either<InspectionOptionResponseEntity, Failure>> getInspectionOptions(
      NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        return await inspectionDataSource.getInspectionOptions(params);
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
  Future<Either<CreateInspectionResponseEntity, Failure>> createInspection(
      FormData params) async {
    if (await networkInfo.isConnected) {
      try {
        return await inspectionDataSource.createInspection(params);
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
