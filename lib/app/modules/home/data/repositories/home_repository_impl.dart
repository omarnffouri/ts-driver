import 'package:ts_driver/app/core/data/connection/network_info.dart';
import 'package:ts_driver/app/core/data/error/exceptions.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/functions.dart';
import 'package:ts_driver/app/modules/home/data/datasources/home_local_datasource.dart';
import 'package:ts_driver/app/modules/home/data/datasources/home_remote_datasource.dart';
import 'package:ts_driver/app/modules/home/domain/entities/applicant_state_entity.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/home/domain/entities/check_clock_in_entity.dart';
import 'package:ts_driver/app/modules/home/domain/repositories/home_repository.dart';

import '../../../../core/services/injection_service.dart';

class HomeRepositoryImpl extends IHomeRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  IHomeRemoteDatasource remoteDatasource = sl<IHomeRemoteDatasource>();
  IHomeLocalDatasource localDatasource = sl<IHomeLocalDatasource>();

  HomeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<ApplicantStateEntity, Failure>> getApplicationState() async {
    if (await networkInfo.isConnected) {
      final response = await remoteDatasource.getApplicationState();
      return response.fold(
        (clockin) {
          localDatasource.cacheApplicationState(clockin);
          return Left(clockin);
        },
        (failure) => Right(failure),
      );
    } else {
      try {
        return await localDatasource.getApplicationState();
      } on EmptyCacheException {
        return const Right(
          EmptyCacheFailure(message: 'No data found , try again later'),
        );
      }
    }
  }

  @override
  Future<Either<CheckClockInDataEntity, Failure>> checkClockIn() async {
    if (await networkInfo.isConnected) {
      return await executeAndHandleError(() => remoteDatasource.checkClockIn());
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<BaseResponse<bool>, Failure>> clockIn() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDatasource.clockIn();
        return response.fold(
          (clockin) => Left(clockin),
          (failure) => Right(failure),
        );
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
  Future<Either<BaseResponse<bool>, Failure>> clockOut() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDatasource.clockOut();
        return response.fold(
          (clockout) => Left(clockout),
          (failure) => Right(failure),
        );
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
  Future<Either<bool, Failure>> updateVoipToken(String params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDatasource.updateVoipToken(params);
        return response.fold(
          (bool resposne) => Left(resposne),
          (failure) => Right(failure),
        );
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
