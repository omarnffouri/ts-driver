import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../entities/truck_entity.dart';
import '../repositories/vehicle_documents_repository.dart';

class GetAllTruckDocumentsUsecase
    extends BaseUseCase<List<TruckEntity>, NoParams> {
  IVehicleDocumentsRepository truckRepository;
  GetAllTruckDocumentsUsecase({required this.truckRepository});

  @override
  Future<Either<List<TruckEntity>, Failure>> call(NoParams params) async {
    return await truckRepository.getAllTruckDocuments();
  }
}
