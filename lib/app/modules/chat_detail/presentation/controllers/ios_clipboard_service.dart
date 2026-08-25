import 'package:flutter/services.dart';

class IosClipboardService {
  final MethodChannel _channel = const MethodChannel('clipboardChannel');

  getImageFromClipboard() async {
    final result = await _channel.invokeMethod('getImageFromClipboard');
    return result;
  }
}
