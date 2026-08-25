import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';

import '../params/update_partner_driver_permission_params.dart';

class UpdatePartnerDriverStateUsecase
    extends BaseUseCase<bool, UpdatePartnerDriverStateParams> {
  final ISettlmentsRepository repository;

  UpdatePartnerDriverStateUsecase({required this.repository});

  @override
  Future<Either<bool, Failure>> call(
      UpdatePartnerDriverStateParams params) async {
    return repository.updatePartnerDriverState(params);
  }
}
