// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReactMessageParams {
  int participantId;
  int messageId;
  String reaction;
  ReactMessageParams({
    required this.messageId,
    required this.participantId,
    required this.reaction,
  });

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'p_id': participantId,
      'reaction': reaction,
    };
  }
}
