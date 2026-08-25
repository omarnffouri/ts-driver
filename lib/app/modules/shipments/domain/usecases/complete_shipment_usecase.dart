import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';
import 'package:dio/dio.dart';

class CompleteShipmentUsecase extends BaseUseCase<ShipmentEntity, FormData> {
  IShipmentRepository shipmentRepository;
  CompleteShipmentUsecase({required this.shipmentRepository});

  @override
  Future<Either<ShipmentEntity, Failure>> call(FormData params) async {
    return await shipmentRepository.completeShipment(params);
  }
}
