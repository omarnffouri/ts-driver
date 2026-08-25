import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/video_repository.dart';

class UpdateVideoUsecase extends BaseUseCase<bool, MapBody> {
  IVideoRepository videoRepository;
  UpdateVideoUsecase({required this.videoRepository});

  @override
  Future<Either<bool, Failure>> call(MapBody params) async {
    return await videoRepository.updateVideo(params);
  }
}
