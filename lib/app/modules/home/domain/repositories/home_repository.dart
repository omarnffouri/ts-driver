import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/home/domain/entities/applicant_state_entity.dart';
import 'package:ts_driver/app/modules/home/domain/entities/check_clock_in_entity.dart';

abstract class IHomeRepository {
  Future<Either<ApplicantStateEntity, Failure>> getApplicationState();
  Future<Either<CheckClockInDataEntity, Failure>> checkClockIn();
  Future<Either<BaseResponse<bool>, Failure>> clockIn();
  Future<Either<BaseResponse<bool>, Failure>> clockOut();
  Future<Either<bool, Failure>> updateVoipToken(String params);
}
