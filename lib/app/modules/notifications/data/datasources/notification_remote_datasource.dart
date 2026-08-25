import 'package:dartz/dartz.dart';

import '../../../../core/data/connection/api_constants.dart';
import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';
import '../../../../core/values/constants.dart';
import '../models/notification_model.dart';

abstract class INotificationRemoteDataSource {
  Future<Either<List<NotificationModel>, Failure>> getAllNotifications();
  Future<Either<bool, Failure>> updateNotification(MapBody body);
}

class NotificationRemoteDataSourceImpl
    implements INotificationRemoteDataSource {
  final DioClient client;
  NotificationRemoteDataSourceImpl({required this.client});
  @override
  Future<Either<List<NotificationModel>, Failure>> getAllNotifications() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getNotifications,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => NotificationModel.fromJson(e))
                .toList();
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> updateNotification(MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateNotification,
        data: body,
        method: RequestType.PUT,
        converter: (response) {
          try {
            return response['data']['status'] == 200;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
