import 'package:dartz/dartz.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/notification_repository.dart';

class UpdateNotificationUsecase extends BaseUseCase<bool, MapBody> {
  INotificationRepository notificationRepository;
  UpdateNotificationUsecase({required this.notificationRepository});

  @override
  Future<Either<bool, Failure>> call(MapBody params) async {
    return await notificationRepository.updateNotification(params);
  }
}
