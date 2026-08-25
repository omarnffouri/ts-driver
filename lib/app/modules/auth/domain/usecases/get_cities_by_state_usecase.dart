import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../entities/region_entity.dart';
import '../repositories/auth_repository.dart';

class GetCitiesByStateUseCase
    extends BaseUseCase<List<RegionEntity>, Map<String, dynamic>> {
  final IAuthRepository authRepository;

  GetCitiesByStateUseCase({required this.authRepository});
  @override
  Future<Either<List<RegionEntity>, Failure>> call(
      Map<String, dynamic> params) async {
    return await authRepository.getCities(params);
  }
}
