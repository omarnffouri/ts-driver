import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoipHelper {
//
//

  static const MethodChannel _channel = MethodChannel('voipChannel');

  static Future<String> fetchVoipToken() async {
    try {
      final token = await _channel.invokeMethod("getVoipToken");

      if (token is String) {
        return token;
      } else {
        return "";
      }
    } catch (e) {
      debugPrint('Error fetching voip token: $e');
      return ""; // There was an error invoking the method
    }
  }
}
