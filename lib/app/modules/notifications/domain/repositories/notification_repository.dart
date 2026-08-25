import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/notifications/domain/entities/notification_entity.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../core/values/constants.dart';

abstract class INotificationRepository {
  Future<Either<List<NotificationEntity>, Failure>> getAllNotifications();
  Future<Either<bool, Failure>> updateNotification(MapBody body);
}
