import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/home/domain/repositories/home_repository.dart';

class ClockOutUsecase extends BaseUseCase<BaseResponse<bool>, NoParams> {
  final IHomeRepository homeRepository;

  ClockOutUsecase({required this.homeRepository});

  @override
  Future<Either<BaseResponse<bool>, Failure>> call(NoParams params) async {
    return homeRepository.clockOut();
  }
}
