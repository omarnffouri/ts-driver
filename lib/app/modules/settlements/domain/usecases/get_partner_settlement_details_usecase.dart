import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';

import '../entities/partner_settlement_details_entity.dart';

class GetPartnerSettlmentDetailsUsecase
    extends BaseUseCase<PartnerSettlementDetailsEntity, String> {
  final ISettlmentsRepository repository;

  GetPartnerSettlmentDetailsUsecase({required this.repository});

  @override
  Future<Either<PartnerSettlementDetailsEntity, Failure>> call(
      String params) async {
    return await repository.getPartnerSettlementDetails(params);
  }
}
