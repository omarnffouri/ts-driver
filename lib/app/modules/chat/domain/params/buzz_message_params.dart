class BuzzMessageParams {
  int converstionId;
  int? messageId;
  BuzzMessageParams({
    required this.converstionId,
    this.messageId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
    };
  }
}
