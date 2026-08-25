import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SocialSecurityNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Get the new value without any non-digit characters.
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length >= 3 && text.length <= 5) {
      return TextEditingValue(
          text:
              '${text.substring(0, 3)}${text.length > 3 ? '-${text.substring(3)}' : ''}',
          selection: TextSelection.fromPosition(
              TextPosition(offset: text.length + (text.length > 3 ? 1 : 0))));
    } else if (text.length > 5 && text.length <= 9) {
      return TextEditingValue(
          text:
              '${text.substring(0, 3)}-${text.substring(3, 5)}${text.length > 5 ? '-${text.substring(5)}' : ''}',
          selection: TextSelection.fromPosition(
              TextPosition(offset: text.length + (text.length > 5 ? 2 : 0))));
    } else if (text.length > 9) {
      return TextEditingValue(
          text:
              '${text.substring(0, 3)}-${text.substring(3, 5)}-${text.substring(5, 9)}',
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
    return newValue;
  }
}

class UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length >= 3 && text.length <= 5) {
      return TextEditingValue(
          text:
              '${text.substring(0, 3)}${text.length > 3 ? '-${text.substring(3)}' : ''}',
          selection: TextSelection.fromPosition(
              TextPosition(offset: text.length + (text.length > 3 ? 1 : 0))));
    } else if (text.length > 5 && text.length <= 10) {
      return TextEditingValue(
        text:
            '${text.substring(0, 3)}-${text.substring(3, 6)}${text.length > 6 ? '-${text.substring(6)}' : ''}',
        selection: TextSelection.fromPosition(
          TextPosition(
            offset: text.length + (text.length >= 7 ? 2 : 1),
          ),
        ),
      );
    } else if (text.length > 10) {
      return TextEditingValue(
          text:
              '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(5, 10)}',
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
    return newValue;
  }
}

// this for register page only
class UsNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newString.length > 10) {
      newString = newString.substring(0, 10);
    }
    String formattedValue = _formatUsNumber(newString);
    return newValue.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length));
  }

  String _formatUsNumber(String input) {
    if (input.length < 3) {
      return input;
    } else if (input.length < 6) {
      return '${input.substring(0, 3)}-${input.substring(3)}'; //'(${input.substring(0, 3)}) ${input.substring(3)}';
    } else {
      return '${input.substring(0, 3)}-${input.substring(3, 6)}-${input.substring(6)}';
    }
  }
}

bool emailInputValidator(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

bool validateControllers({List<TextEditingController>? textEditingController}) {
  if (textEditingController == null) {
    return false;
  }

  return textEditingController
      .every((controller) => controller.text.isNotEmpty);
}

emptyControllers({List<TextEditingController>? textEditingController}) {
  textEditingController?.forEach((element) {
    if (element.text.isNotEmpty) {
      element.clear();
    }
  });
}
