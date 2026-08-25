import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/form_entity.dart';
import 'package:ts_driver/app/modules/forms/domain/repositories/form_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class GetAllFormsUsecase extends BaseUseCase<List<FormEntity>, NoParams> {
  IFormRepository formRepository;
  GetAllFormsUsecase({required this.formRepository});

  @override
  Future<Either<List<FormEntity>, Failure>> call(params) async {
    return await formRepository.getAllForms();
  }
}
