import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/notifications/data/models/notification_model.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl extends INotificationRepository {
  INotificationRemoteDataSource notificationRemoteDataSource =
      sl<INotificationRemoteDataSource>();
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  NotificationRepositoryImpl({required this.notificationRemoteDataSource});
  @override
  Future<Either<List<NotificationModel>, Failure>> getAllNotifications() async {
    if (await networkInfo.isConnected) {
      try {
        final notificationsResponse =
            await notificationRemoteDataSource.getAllNotifications();
        return notificationsResponse.fold(
          (List<NotificationModel> videos) => Left(videos),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> updateNotification(MapBody body) async {
    if (await networkInfo.isConnected) {
      try {
        final getVideosResponse =
            await notificationRemoteDataSource.updateNotification(body);
        return getVideosResponse.fold(
          (succ) => Left(succ),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }
}
