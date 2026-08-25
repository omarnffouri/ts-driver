import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/partner_driver_entity.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_data_entiity.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_details_entity.dart';
import 'package:ts_driver/app/modules/settlements/domain/params/settlments_params.dart';

import '../entities/partner_settlement_data_entity.dart';
import '../entities/partner_settlement_details_entity.dart';
import '../params/update_partner_driver_permission_params.dart';

abstract class ISettlmentsRepository {
  Future<Either<BaseResponse<List<SettlementDataEntity>>, Failure>>
      getAllSettlements(
    SettlementParams params,
  );

  Future<Either<SettlementDetailsEntity, Failure>> getSettlementDetails(
    String settlementId,
  );

  Future<Either<List<PartnerSettlementEntity>, Failure>>
      getAllPartnerSettlements(
    SettlementParams params,
  );

  Future<Either<PartnerSettlementDetailsEntity, Failure>>
      getPartnerSettlementDetails(
    String settlementId,
  );
  Future<Either<List<PartnerDriverEntity>, Failure>> getPartnerDrivers();

  Future<Either<bool, Failure>> updatePartnerDriverState(
      UpdatePartnerDriverStateParams params);
}
