import 'package:flutter/services.dart';

class MessageInputFormatter extends TextInputFormatter {
  bool addingBullets = false;
  bool addingNumbers = false;
  int currentNumber = 1;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
    String oldText = oldValue.text;

    //
    //
    // check if adding bullets and its the end of line
    if (newText.endsWith("\n") && addingBullets) {
      //
      // check if user is removing the bullets
      if (oldText.endsWith("*") || oldText.endsWith("-")) {
        addingBullets = false;
        return newValue;
      }
      //
      // else add bullet to new line
      else {
        final bulletText = "$newText* ";
        return TextEditingValue(
          text: bulletText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: bulletText.length),
          ),
        );
      }
    }

    //
    //
    // check if adding numbers and its the end of line
    else if (newText.endsWith("\n") && addingNumbers) {
      //
      // This regex checks if the string ends with digits (one or more)
      final regex = RegExp(r'\d+$');

      //
      // check if user is removing the numbers
      if (regex.hasMatch(oldText)) {
        currentNumber = 1;
        addingNumbers = false;
        return newValue;
      }

      //
      // else add number to new line
      else {
        final numberedText = "$newText${++currentNumber}. ";

        return TextEditingValue(
          text: numberedText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: numberedText.length),
          ),
        );
      }
    }

    //
    //
    // check if user moved to new line last text line was a bullet or numbered then
    // add bullet or number to next line
    else if (newText.endsWith("\n")) {
      final lines = newText.split("\n");
      if (lines.isNotEmpty) {
        //
        final lastTextLine = lines[lines.length - 2];

        // check if last line was a bulleted list then start adding bullets
        if (lastTextLine.startsWith("* ") || lastTextLine.startsWith("- ")) {
          addingBullets = true;
          final bulletText = "$newText* ";
          return TextEditingValue(
            text: bulletText,
            selection: TextSelection.fromPosition(
              TextPosition(offset: bulletText.length),
            ),
          );
        }
        //
        //
        // else check if last line was a numbered list then start adding numbers
        else {
          // Regex pattern checks that line starts with number
          final regex = RegExp(r'^(\d+)\. ');

          final match = regex.firstMatch(lastTextLine);
          if (match != null) {
            // Extract the captured number
            final number = match.group(1);

            try {
              currentNumber = int.parse(number ?? "1");
            } catch (_) {}

            final numberedText = "$newText${++currentNumber}. ";

            addingNumbers = true;
            return TextEditingValue(
              text: numberedText,
              selection: TextSelection.fromPosition(
                TextPosition(offset: numberedText.length),
              ),
            );
          }
        }
      }
    }

    // Check if "* " or "- " was typed at the end of the text to add bullet
    // and addingBullets was false make it true
    else if ((newText.endsWith("* ") || newText.endsWith("- ")) &&
        !addingBullets) {
      addingBullets = true;
      return newValue;
    }

    //
    //
    // Check if any number and . was typed at the end of the text to add numbered list
    // and addingNumbers was false make it true
    else {
      final regex = RegExp(r'(\d+)\.$');
      final match = regex.firstMatch(newText);
      if (match != null) {
        // Extract the captured number
        final number = match.group(1);

        try {
          currentNumber = int.parse(number ?? "1");
        } catch (_) {}

        addingNumbers = true;
      }
    }

    //
    // default
    return newValue;
  }
}
