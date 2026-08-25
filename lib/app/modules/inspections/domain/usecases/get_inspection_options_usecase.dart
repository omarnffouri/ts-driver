import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../entities/inspection_options_entity.dart';
import '../repositories/inspection_repository.dart';

class GetInspectionOptionsUseCase
    extends BaseUseCase<InspectionOptionResponseEntity, NoParams> {
  IInspectionRepository inspectionRepository;
  GetInspectionOptionsUseCase({required this.inspectionRepository});

  @override
  Future<Either<InspectionOptionResponseEntity, Failure>> call(
      NoParams params) async {
    return await inspectionRepository.getInspectionOptions(params);
  }
}
