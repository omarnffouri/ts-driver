import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeCallingMethodChannel {
  static const MethodChannel _channel =
      MethodChannel('native_calling_method_channel');

  static Future<bool> placeCall(Map<String, dynamic> callDetails) async {
    try {
      final result = await _channel.invokeMethod("place_call", callDetails);
      return result == true;
    } catch (e) {
      debugPrint(
          "Exception while placing call in flutter method channel === $e");
      return false;
    }
  }

  static Future<bool> openNativeCallUI(String callID) async {
    try {
      final result = await _channel.invokeMethod("open_native_call_ui", callID);
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canStartCall() async {
    try {
      final result = await _channel.invokeMethod("can_start_call");
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> endCall(String callID) async {
    try {
      final result = await _channel.invokeMethod("end_call", callID);
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> getCurrentCall() async {
    try {
      return await _channel.invokeMethod("get_current_call");
    } catch (_) {
      return false;
    }
  }
}
