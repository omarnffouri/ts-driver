import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/signed_form_entity.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/form_repository.dart';

class GetAllSignedFormsUsecase
    extends BaseUseCase<List<SignedFormEntity>, NoParams> {
  IFormRepository formRepository;
  GetAllSignedFormsUsecase({required this.formRepository});

  @override
  Future<Either<List<SignedFormEntity>, Failure>> call(params) async {
    return await formRepository.getAllSignedForms();
  }
}
