import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';
import '../entities/partner_settlement_data_entity.dart';
import '../params/settlments_params.dart';

class GetAllPartnerSettlmentsUsecase
    extends BaseUseCase<List<PartnerSettlementEntity>, SettlementParams> {
  final ISettlmentsRepository repository;

  GetAllPartnerSettlmentsUsecase({required this.repository});

  @override
  Future<Either<List<PartnerSettlementEntity>, Failure>> call(
      SettlementParams params) async {
    return await repository.getAllPartnerSettlements(params);
  }
}
