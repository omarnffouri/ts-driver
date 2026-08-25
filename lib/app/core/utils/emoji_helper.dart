class EmojiHelper {
  //
  // checking is string emoji or not
  static bool isEmoji(String string) {
    if (string.isEmpty) {
      return false;
    }
    if (string.runes.length == 1) {
      final firstRune = string.runes.first;
      return (0x1F600 <= firstRune && firstRune <= 0x1F64F) ||
          (0x1F300 <= firstRune && firstRune <= 0x1F5FF) ||
          (0x1F680 <= firstRune && firstRune <= 0x1F6FF) ||
          (0x2600 <= firstRune && firstRune <= 0x26FF) ||
          (0x2700 <= firstRune && firstRune <= 0x27BF) ||
          (0x1F900 <= firstRune && firstRune <= 0x1F9FF);
    }
    return false;
  }

//
// checking is string contains emoji or not
  static bool containsEmoji(String text) {
    // for (int i = 0; i < text.length; i++) {
    //   String character = text[i];

    //   if (isEmoji(character)) {
    //     return true;
    //   }
    // }
    for (int rune in text.runes) {
      var character = String.fromCharCode(rune);
      if (isEmoji(character)) {
        // If the character has more than one rune, it's likely an emoji
        return true;
      }
    }
    return false;
  }
}
