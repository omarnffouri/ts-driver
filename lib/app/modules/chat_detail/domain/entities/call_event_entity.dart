import 'package:equatable/equatable.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/call_notification_payload_entity.dart';

class CallEventEntity extends Equatable {
  final bool? error;
  final String? message;
  final CallNotificationPayloadEntity? callPayload;

  const CallEventEntity({
    this.error,
    this.message,
    this.callPayload,
  });

  factory CallEventEntity.fromJson(Map<String, dynamic> json) =>
      CallEventEntity(
        error: json["error"],
        message: json["message"],
        callPayload: json["notificationPayload"] == null
            ? null
            : CallNotificationPayloadEntity.fromJson(
                json["notificationPayload"],
              ),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "notificationPayload": callPayload?.toJson(),
      };

  @override
  List<Object?> get props => [
        error,
        message,
        callPayload,
      ];
}
