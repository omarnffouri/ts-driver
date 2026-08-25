import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/annoucments/domain/entities/annoucement_entity.dart';

abstract class IAnnoucementsRepository {
  Future<Either<List<AnnoucementEntity>, Failure>> getAllAnnoucements();
  Future<Either<bool, Failure>> updateAnnoucementReadStatus(int annoucementId);
}
