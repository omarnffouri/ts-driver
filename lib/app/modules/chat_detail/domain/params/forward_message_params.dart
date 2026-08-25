// ignore_for_file: public_member_api_docs, sort_constructors_first
class ForwardMessageParams {
  List<int> conversations;
  int messageId;

  ForwardMessageParams({required this.messageId, required this.conversations});

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'conversations': List<dynamic>.from(conversations.map((x) => x))
    };
  }
}
