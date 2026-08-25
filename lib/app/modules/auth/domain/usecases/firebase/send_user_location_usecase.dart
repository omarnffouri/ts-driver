import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/values/constants.dart';

import '../../repositories/firebase_repository.dart';

class SendUserLocationUsecase extends BaseUseCase<void, MapBody> {
  final IFirebaseRepository authRepository;

  SendUserLocationUsecase(this.authRepository);
  @override
  Future<Either<void, Failure>> call(MapBody params) async {
    return await authRepository.sendUserLocation(params);
  }
}
