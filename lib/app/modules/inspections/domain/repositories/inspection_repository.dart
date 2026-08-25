import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../../../../core/data/error/failures.dart';
import '../entities/create_inspection_response_entity.dart';
import '../entities/inspection_options_entity.dart';

abstract class IInspectionRepository {
  Future<Either<InspectionOptionResponseEntity, Failure>> getInspectionOptions(
      NoParams params);
  Future<Either<CreateInspectionResponseEntity, Failure>> createInspection(
      FormData params);
}
