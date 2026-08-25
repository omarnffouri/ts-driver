import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/videos/data/models/video_model.dart';
import 'package:ts_driver/app/modules/videos/domain/repositories/video_repository.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/services/injection_service.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl extends IVideoRepository {
  IVideoRemoteDataSource videoRemoteDataSource = sl<IVideoRemoteDataSource>();
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  VideoRepositoryImpl({required this.videoRemoteDataSource});
  @override
  Future<Either<List<VideoModel>, Failure>> getVideos() async {
    if (await networkInfo.isConnected) {
      try {
        final getAllFormsResponse = await videoRemoteDataSource.getVideos();
        return getAllFormsResponse.fold(
          (List<VideoModel> videos) => Left(videos),
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
  Future<Either<bool, Failure>> updateVideo(MapBody body) async {
    if (await networkInfo.isConnected) {
      try {
        final getVideosResponse = await videoRemoteDataSource.updateVideo(body);
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
