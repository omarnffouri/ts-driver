import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

class GetAllVideosUsecase extends BaseUseCase<List<VideoEntity>, NoParams> {
  IVideoRepository videoRepository;
  GetAllVideosUsecase({required this.videoRepository});

  @override
  Future<Either<List<VideoEntity>, Failure>> call(NoParams params) async {
    return await videoRepository.getVideos();
  }
}
