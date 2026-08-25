import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../repositories/auth_repository.dart';

class UpdateFcmTokenUseCase extends BaseUseCase<bool, Map<String, dynamic>> {
  final IAuthRepository authRepository;
  UpdateFcmTokenUseCase({required this.authRepository});

  @override
  Future<Either<bool, Failure>> call(Map<String, dynamic> params) async {
    return await authRepository.updateFCM(params);
  }
}
