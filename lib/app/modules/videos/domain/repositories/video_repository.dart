import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';
import '../entities/video_entity.dart';

abstract class IVideoRepository {
  Future<Either<List<VideoEntity>, Failure>> getVideos();
  Future<Either<bool, Failure>> updateVideo(MapBody body);
}
