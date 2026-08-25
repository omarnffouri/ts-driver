import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase extends BaseUseCase<UserEntity, Map<String, dynamic>> {
  final IAuthRepository authRepository;
  LoginUseCase({required this.authRepository});

  @override
  Future<Either<UserEntity, Failure>> call(Map<String, dynamic> params) async {
    return await authRepository.login(params);
  }
}
