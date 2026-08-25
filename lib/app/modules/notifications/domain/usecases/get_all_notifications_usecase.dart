import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/notifications/domain/entities/notification_entity.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../repositories/notification_repository.dart';

class GetAllNotificationsUsecase
    extends BaseUseCase<List<NotificationEntity>, NoParams> {
  INotificationRepository notificationRepository;
  GetAllNotificationsUsecase({required this.notificationRepository});

  @override
  Future<Either<List<NotificationEntity>, Failure>> call(
      NoParams params) async {
    return await notificationRepository.getAllNotifications();
  }
}
