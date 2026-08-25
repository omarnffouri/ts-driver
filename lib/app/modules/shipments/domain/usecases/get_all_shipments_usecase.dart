import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/shipment_repository.dart';

class GetAllShipmentsUsecase extends BaseUseCase<
    BaseResponse<List<ShipmentEntity>>, Map<String, dynamic>> {
  IShipmentRepository shipmentRepository = sl<IShipmentRepository>();
  GetAllShipmentsUsecase({required this.shipmentRepository});

  @override
  Future<Either<BaseResponse<List<ShipmentEntity>>, Failure>> call(
      Map<String, dynamic> params) async {
    return await shipmentRepository.getAllShipments(params);
  }
}
