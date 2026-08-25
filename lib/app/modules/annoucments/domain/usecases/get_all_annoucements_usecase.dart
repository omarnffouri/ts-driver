import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/annoucments/domain/entities/annoucement_entity.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/annoucements_repository.dart';

class GetAllAnnoucementsUsecase
    extends BaseUseCase<List<AnnoucementEntity>, NoParams> {
  IAnnoucementsRepository annoucementsRepository;
  GetAllAnnoucementsUsecase({required this.annoucementsRepository});

  @override
  Future<Either<List<AnnoucementEntity>, Failure>> call(NoParams params) async {
    return await annoucementsRepository.getAllAnnoucements();
  }
}
