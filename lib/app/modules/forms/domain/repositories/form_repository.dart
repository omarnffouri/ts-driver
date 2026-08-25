import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/form_entity.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/signed_form_entity.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';

abstract class IFormRepository {
  Future<Either<List<FormEntity>, Failure>> getAllForms();
  Future<Either<List<SignedFormEntity>, Failure>> getAllSignedForms();
  Future<Either<bool, Failure>> signForm(MapBody params);
  Future<Either<bool, Failure>> updateAttachmentStatus(MapBody params);
}
