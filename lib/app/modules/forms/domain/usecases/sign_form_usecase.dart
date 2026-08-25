import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/form_repository.dart';

class SignFormUsecase extends BaseUseCase<bool, Map<String, dynamic>> {
  IFormRepository formRepository;
  SignFormUsecase({required this.formRepository});

  @override
  Future<Either<bool, Failure>> call(Map<String, dynamic> params) async {
    return await formRepository.signForm(params);
  }
}
