import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import '../entities/app_configration_entity.dart';
import '../entities/region_entity.dart';
import '../entities/realtime_configuration_entity.dart';
import '../entities/user_entity.dart';

typedef Body = Map<String, dynamic>;

abstract class IAuthRepository {
  Future<Either<UserEntity, Failure>> login(Body body);
  Future<Either<bool, Failure>> logout();
  Future<Either<UserEntity, Failure>> register(Body body);
  Future<Either<UserEntity, Failure>> updateProfile(Body body);
  Future<Either<UserEntity, Failure>> fetchExistingProfile(Body body);
  Future<Either<bool, Failure>> checkEmailVerification(Body body);
  Future<Either<bool, Failure>> deleteAccount();
  Future<Either<UserEntity, Failure>> getProfile();
  Future<Either<bool, Failure>> updateFCM(Body body);
  Future<Either<bool, Failure>> sendOtp(Body body);
  Future<Either<UserEntity, Failure>> verifyOtp(Body body);
  Future<Either<bool, Failure>> verifyRegisterOtp(Body body);
  Future<Either<List<RegionEntity>, Failure>> getCities(Body body);
  Future<Either<AppConfiguration, Failure>> getAppConfigration();
  Future<Either<RealtimeConfiguration, Failure>> getRealtimeConfiguration();
}
