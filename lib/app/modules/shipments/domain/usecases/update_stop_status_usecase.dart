import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/shipment_repository.dart';

class UpdateStopStatusUsecase extends BaseUseCase<bool, Map<String, dynamic>> {
  IShipmentRepository shipmentRepository;
  UpdateStopStatusUsecase({required this.shipmentRepository});

  @override
  Future<Either<bool, Failure>> call(Map<String, dynamic> params) async {
    return await shipmentRepository.stopReached(params);
  }
}
