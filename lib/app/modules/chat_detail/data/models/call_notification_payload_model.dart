import 'package:ts_driver/app/modules/chat_detail/domain/entities/call_notification_payload_entity.dart';

class CallNotificationPayloadModel extends CallNotificationPayloadEntity {
  const CallNotificationPayloadModel({
    super.channelName,
    super.conversationId,
    super.messageId,
    super.callType,
    super.callerId,
    super.conversationType,
    super.callerModelType,
    super.callerName,
    super.callerImage,
    super.callPlacedAt,
    super.tempCallId,
    super.receiverName,
    super.receiverImage,
  });

  factory CallNotificationPayloadModel.fromJson(Map<String, dynamic> json) =>
      CallNotificationPayloadModel(
        channelName: json["channelName"],
        conversationId: int.parse(json["conversationId"].toString()),
        messageId: int.parse((json["messageId"] ?? 0).toString()),
        callType: json["callType"],
        conversationType: json["conversationType"] ?? "oto",
        callerId: int.parse(json["caller_id"].toString()),
        callerModelType: json["caller_model_type"],
        callerName: json["caller_name"],
        callerImage: json["caller_image"],
        callPlacedAt: json["call_placed_at"]?.toString(),
        tempCallId: json["temp_call_id"],
        receiverName: json["receiverName"],
        receiverImage: json["receiverImage"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "channelName": channelName,
        "conversationId": conversationId,
        "messageId": messageId,
        "callType": callType,
        "caller_id": callerId,
        "conversationType": conversationType,
        "caller_model_type": callerModelType,
        "caller_name": callerName,
        "caller_image": callerImage,
        "call_placed_at": callPlacedAt,
        "temp_call_id": tempCallId,
        "receiverName": receiverName,
        "receiverImage": receiverImage,
      };
}
