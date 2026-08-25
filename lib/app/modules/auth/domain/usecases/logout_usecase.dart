import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase extends BaseUseCase<bool, NoParams> {
  final IAuthRepository authRepository;
  LogoutUseCase({required this.authRepository});

  @override
  Future<Either<bool, Failure>> call(NoParams params) async {
    return await authRepository.logout();
  }
}
