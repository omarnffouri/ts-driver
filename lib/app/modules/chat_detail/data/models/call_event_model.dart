import 'package:ts_driver/app/modules/chat_detail/data/models/call_notification_payload_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/call_event_entity.dart';

class CallEventModel extends CallEventEntity {
  const CallEventModel({
    super.error,
    super.message,
    super.callPayload,
  });

  factory CallEventModel.fromJson(Map<String, dynamic> json) => CallEventModel(
        error: json["error"],
        message: json["message"],
        callPayload: json["notificationPayload"] == null
            ? null
            : CallNotificationPayloadModel.fromJson(
                json["notificationPayload"],
              ),
      );

  @override
  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "notificationPayload": callPayload?.toJson(),
      };
}
