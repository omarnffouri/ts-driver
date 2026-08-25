import 'package:flutter/services.dart';

class ClipboardHelper {
  /// This function will copy plain text/string to clipboard as plain text
  static Future copyPlainText(String plainText) async {
    Clipboard.setData(ClipboardData(text: plainText));
  }

  /// This function will check for the plain text in clipboard and return plain text as String?
  static Future<String?> readPlainText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
