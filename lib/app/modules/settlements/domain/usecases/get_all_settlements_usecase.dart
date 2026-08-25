import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_data_entiity.dart';
import 'package:ts_driver/app/modules/settlements/domain/params/settlments_params.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

class GetAllSettlmentsUsecase extends BaseUseCase<
    BaseResponse<List<SettlementDataEntity>>, SettlementParams> {
  final ISettlmentsRepository repository;

  GetAllSettlmentsUsecase({required this.repository});

  @override
  Future<Either<BaseResponse<List<SettlementDataEntity>>, Failure>> call(
    SettlementParams params,
  ) async {
    return await repository.getAllSettlements(params);
  }
}
