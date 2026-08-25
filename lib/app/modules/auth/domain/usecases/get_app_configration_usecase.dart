import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import '../entities/app_configration_entity.dart';
import '../repositories/auth_repository.dart';

class GetAppConfigrationUseCase
    extends BaseUseCase<AppConfiguration, NoParams> {
  final IAuthRepository authRepository;

  GetAppConfigrationUseCase({required this.authRepository});

  @override
  Future<Either<AppConfiguration, Failure>> call(NoParams params) async {
    return await authRepository.getAppConfigration();
  }
}
