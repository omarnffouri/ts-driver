import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/partner_driver_entity.dart';
import 'package:ts_driver/app/modules/settlements/domain/repositories/settlments_repository.dart';

class GetPartnerDriversUseCase
    extends BaseUseCase<List<PartnerDriverEntity>, NoParams> {
  final ISettlmentsRepository repository;

  GetPartnerDriversUseCase({required this.repository});
  @override
  Future<Either<List<PartnerDriverEntity>, Failure>> call(
      NoParams params) async {
    return await repository.getPartnerDrivers();
  }
}
