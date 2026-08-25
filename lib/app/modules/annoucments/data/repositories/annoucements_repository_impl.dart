import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/network_info.dart';
import 'package:ts_driver/app/core/data/error/exceptions.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/annoucments/data/models/annoucement_model.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/annoucements_repository.dart';
import '../datasources/annoucements_remote_datasource.dart';

class AnnoucementsRepositoryImpl extends IAnnoucementsRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  IAnnoucementsRemoteDataSource dataSource;

  AnnoucementsRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<List<AnnoucementModel>, Failure>> getAllAnnoucements() async {
    if (await networkInfo.isConnected) {
      try {
        final annoucementsResponse = await dataSource.getAllAnnoucements();
        return annoucementsResponse.fold(
          (List<AnnoucementModel> annoucements) => Left(annoucements),
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
  Future<Either<bool, Failure>> updateAnnoucementReadStatus(
      int annoucementId) async {
    if (await networkInfo.isConnected) {
      try {
        final getVideosResponse =
            await dataSource.updateAnnoucementReadStatus(annoucementId);
        return getVideosResponse.fold(
          (succ) => Left(succ),
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
