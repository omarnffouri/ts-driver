// ignore_for_file: public_member_api_docs, sort_constructors_first
class SendTextMessageParams {
  final String message;
  final String tempId;
  final String conversationId;
  final String? type;
  final int? replyOnMessageId;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? gifInfo;

  SendTextMessageParams({
    required this.message,
    required this.tempId,
    required this.conversationId,
    this.replyOnMessageId,
    this.latitude,
    this.type,
    this.longitude,
    this.gifInfo,
  });
}
