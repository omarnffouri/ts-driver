import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/entities/truck_entity.dart';

import '../../../../core/data/error/failures.dart';
import '../entities/trailer_entity.dart';

abstract class IVehicleDocumentsRepository {
  Future<Either<List<TruckEntity>, Failure>> getAllTruckDocuments();
  Future<Either<List<TrailerEntity>, Failure>> getAllTrailerDocuments();
}
