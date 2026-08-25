import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../entities/trailer_entity.dart';
import '../repositories/vehicle_documents_repository.dart';

class GetAllTrailerDocumentsUsecase
    extends BaseUseCase<List<TrailerEntity>, NoParams> {
  IVehicleDocumentsRepository truckRepository;
  GetAllTrailerDocumentsUsecase({required this.truckRepository});

  @override
  Future<Either<List<TrailerEntity>, Failure>> call(NoParams params) async {
    return await truckRepository.getAllTrailerDocuments();
  }
}
