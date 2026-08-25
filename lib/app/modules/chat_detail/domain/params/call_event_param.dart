// To parse this JSON data, do
//
//     final callEventParam = callEventParamFromJson(jsonString);

import 'dart:convert';

String callEventParamToJson(CallEventParam data) => json.encode(data.toJson());

class CallEventParam {
  final String eventName;
  final Map<String, dynamic>? eventDetails;

  CallEventParam({
    required this.eventName,
    this.eventDetails,
  });

  Map<String, dynamic> toJson() => {
        "eventName": eventName,
        "eventDetails": eventDetails,
      };
}
