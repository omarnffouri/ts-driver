import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';

class GetShipmentDetailsUsecase
    extends BaseUseCase<ShipmentEntity, Map<String, dynamic>> {
  IShipmentRepository shipmentRepository = sl<IShipmentRepository>();
  GetShipmentDetailsUsecase({required this.shipmentRepository});

  @override
  Future<Either<ShipmentEntity, Failure>> call(
      Map<String, dynamic> params) async {
    return await shipmentRepository.getShipmentDetails(params);
  }
}
