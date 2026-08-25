import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_details_entity.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class GetSettlmentDetailsUsecase
    extends BaseUseCase<SettlementDetailsEntity, String> {
  final ISettlmentsRepository repository;

  GetSettlmentDetailsUsecase({required this.repository});

  @override
  Future<Either<SettlementDetailsEntity, Failure>> call(
    String params,
  ) async {
    return await repository.getSettlementDetails(params);
  }
}
