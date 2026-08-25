import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/annoucements_repository.dart';

class UpdateAnnoucementReadStatusUsecase extends BaseUseCase<bool, int> {
  IAnnoucementsRepository annoucementsRepository;
  UpdateAnnoucementReadStatusUsecase({required this.annoucementsRepository});

  @override
  Future<Either<bool, Failure>> call(int params) async {
    return await annoucementsRepository.updateAnnoucementReadStatus(params);
  }
}
