import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../entities/create_inspection_response_entity.dart';
import '../repositories/inspection_repository.dart';

class CreateInspectionUserCase
    extends BaseUseCase<CreateInspectionResponseEntity, FormData> {
  IInspectionRepository inspectionRepository;
  CreateInspectionUserCase({required this.inspectionRepository});

  @override
  Future<Either<CreateInspectionResponseEntity, Failure>> call(
      FormData params) async {
    return await inspectionRepository.createInspection(params);
  }
}
