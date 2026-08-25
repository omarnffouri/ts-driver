import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/realtime_configuration_entity.dart';
import 'package:ts_driver/app/modules/auth/domain/repositories/auth_repository.dart';

class GetRealtimeConfigurationUseCase
    extends BaseUseCase<RealtimeConfiguration, NoParams> {
  final IAuthRepository authRepository;

  GetRealtimeConfigurationUseCase({required this.authRepository});

  @override
  Future<Either<RealtimeConfiguration, Failure>> call(NoParams params) async {
    return await authRepository.getRealtimeConfiguration();
  }
}
