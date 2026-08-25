import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/home/domain/entities/check_clock_in_entity.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/home_repository.dart';

class CheckClockInUsecase
    extends BaseUseCase<CheckClockInDataEntity, NoParams> {
  final IHomeRepository homeRepository;

  CheckClockInUsecase({required this.homeRepository});

  @override
  Future<Either<CheckClockInDataEntity, Failure>> call(NoParams params) async {
    return homeRepository.checkClockIn();
  }
}
