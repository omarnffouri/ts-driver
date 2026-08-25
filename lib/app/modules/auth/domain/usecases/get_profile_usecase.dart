import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase extends BaseUseCase<UserEntity, NoParams> {
  final IAuthRepository authRepository;
  GetProfileUseCase({required this.authRepository});

  @override
  Future<Either<UserEntity, Failure>> call(NoParams params) async {
    return await authRepository.getProfile();
  }
}
