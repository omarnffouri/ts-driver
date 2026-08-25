import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/native_calling/enums/native_calling_events.dart';
import 'package:ts_driver/app/native_calling/models/native_calling_event.dart';

class NativeCallingEventChannel {
  static const EventChannel _eventChannel =
      EventChannel('native_calling_event_channel');

  static Stream<NativeCallingEvent?> get onEvent =>
      _eventChannel.receiveBroadcastStream().map(_receiveCallingEvent);

  static NativeCallingEvent? _receiveCallingEvent(dynamic data) {
    NativeCallingEvents? event;
    Map<String, dynamic> body = {};

    if (data is Map) {
      event = NativeCallingEvents.values
          .firstWhereOrNull((e) => e.name == data['event']);

      if (event == null) {
        return null;
      }

      if (data['data'] == null) {
        return null;
      }

      body = Map<String, dynamic>.from(data['data']);
      return NativeCallingEvent(event, body);
    }
    return null;
  }
}
