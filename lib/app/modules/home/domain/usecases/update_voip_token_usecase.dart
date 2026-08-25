import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/home/domain/repositories/home_repository.dart';

class UpdateVoipTokenUsecase extends BaseUseCase<bool, String> {
  final IHomeRepository repository;

  UpdateVoipTokenUsecase({required this.repository});

  @override
  Future<Either<bool, Failure>> call(String params) async {
    return await repository.updateVoipToken(params);
  }
}
