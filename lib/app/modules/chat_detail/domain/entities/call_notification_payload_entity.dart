import 'package:equatable/equatable.dart';

class CallNotificationPayloadEntity extends Equatable {
  final String? channelName;
  final int? conversationId;
  final int? messageId;
  final String? callType;
  final String? conversationType;
  final int? callerId;
  final String? callerModelType;
  final String? callerName;
  final String? callerImage;
  final String? callPlacedAt;
  final String? tempCallId;
  final String? receiverName;
  final String? receiverImage;

  const CallNotificationPayloadEntity({
    this.channelName,
    this.conversationId,
    this.messageId,
    this.callType,
    this.callerId,
    this.conversationType,
    this.callerModelType,
    this.callerName,
    this.callerImage,
    this.callPlacedAt,
    this.tempCallId,
    this.receiverName,
    this.receiverImage,
  });

  factory CallNotificationPayloadEntity.fromJson(Map<String, dynamic> json) =>
      CallNotificationPayloadEntity(
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

  @override
  List<Object?> get props => [
        channelName,
        conversationId,
        messageId,
        callType,
        callerId,
        conversationType,
        callerModelType,
        callerName,
        callerImage,
        callPlacedAt,
        tempCallId,
        receiverName,
        receiverImage,
      ];
}
