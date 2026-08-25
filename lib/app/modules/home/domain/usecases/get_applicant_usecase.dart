import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/home/domain/entities/applicant_state_entity.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/home_repository.dart';

class GetApplicantUsecase extends BaseUseCase<ApplicantStateEntity, NoParams> {
  final IHomeRepository homeRepository;
  GetApplicantUsecase({required this.homeRepository});

  @override
  Future<Either<ApplicantStateEntity, Failure>> call(NoParams params) {
    return homeRepository.getApplicationState();
  }
}
