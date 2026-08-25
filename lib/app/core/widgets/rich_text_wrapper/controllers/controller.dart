import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/match_target_item.dart';

/// a custom controller based on [TextEditingController] used to activly style input text based on regex patterns and word matching
/// with some custom features.

class RichTextController extends TextEditingController {
  final List<MatchTargetItem> targetMatches;
  final Function(List<String> match) onMatch;
  final Function(List<Map<String, List<int>>>)? onMatchIndex;
  final bool? deleteOnBack;
  //
  String _lastValue = "";

  /// controls the caseSensitive property of the full [RegExp] used to pattern match
  final bool regExpCaseSensitive;

  /// controls the dotAll property of the full [RegExp] used to pattern match
  final bool regExpDotAll;

  /// controls the multiLine property of the full [RegExp] used to pattern match
  final bool regExpMultiLine;

  /// controls the unicode property of the full [RegExp] used to pattern match
  final bool regExpUnicode;

  bool isBack(String current, String last) {
    return current.length < last.length;
  }

  RichTextController({
    super.text,
    required this.targetMatches,
    required this.onMatch,
    this.onMatchIndex,
    this.deleteOnBack = false,
    this.regExpCaseSensitive = true,
    this.regExpDotAll = false,
    this.regExpMultiLine = false,
    this.regExpUnicode = false,
  });

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]).
  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  /// Builds [TextSpan] from current editing value.
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<TextSpan> children = [];
    final matches = <String>{};
    List<Map<String, List<int>>> matchIndex = [];
    // combined regex!
    String regItemText = '';
    String stringItemText = '';
    for (MatchTargetItem target in targetMatches) {
      //
      if (target.regex != null) {
        regItemText =
            '${regItemText.isNotEmpty ? '$regItemText|' : regItemText}${!target.allowInlineMatching ? '\\b' : ''}${target.regex!.pattern}';
      }
      if (target.text != null) {
        stringItemText =
            '${stringItemText.length > 1 ? '$stringItemText|' : stringItemText}${!target.allowInlineMatching ? '\\b' : ''}${target.text}';
      }
      //
    }

    List<TextSpan> bulletChildren = [];

    // Define the bullet-point regex pattern to match lines beginning with "* "
    final bulletRegex = RegExp(r'^([*-] )(.*)', multiLine: true);

    // Split the text into spans based on bullet lines
    text.splitMapJoin(
      bulletRegex,
      onNonMatch: (String span) {
        bulletChildren.add(TextSpan(text: span, style: style));
        return span.toString();
      },
      onMatch: (Match m) {
        final bulletContent = m.group(2) ?? '';

        // Add the bullet point as a TextSpan without altering the controller text
        bulletChildren.addAll([
          TextSpan(
            text: '• ',
            style: style?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: bulletContent, style: style),
        ]);

        return '';
      },
    );

    final bulletText = TextSpan(children: bulletChildren).toPlainText();

    // combined regex!
    RegExp allRegex = RegExp(
        (stringItemText.length > 1 ? "$stringItemText|" : stringItemText) +
            regItemText,
        multiLine: regExpMultiLine,
        caseSensitive: regExpCaseSensitive,
        dotAll: regExpDotAll,
        unicode: regExpUnicode);
    //
    bulletText.splitMapJoin(
      allRegex,
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span.toString();
      },
      onMatch: (Match m) {
        matches.add(m[0]!);
        //
        final MatchTargetItem? matchedItem =
            targetMatches.firstWhereOrNull((e) {
          return (e.regex != null
              ? e.regex!.allMatches(m[0]!).isNotEmpty
              : e.text!.allMatches(m[0]!).isNotEmpty);
        });

        // Split the matched text into start special character, main text, and end special character
        String? matchedText = m[0];
        String? startChar = matchedText?.substring(0, 1);
        String? mainText = matchedText?.substring(1, matchedText.length - 1);
        String? endChar = matchedText?.substring(matchedText.length - 1);

        //
        if (deleteOnBack!) {
          if ((isBack(text, _lastValue) && m.end == selection.baseOffset)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              children.removeWhere((element) => element.text! == text);
              text = text.replaceRange(m.start, m.end, "");
              selection = selection.copyWith(
                baseOffset: m.end - (m.end - m.start),
                extentOffset: m.end - (m.end - m.start),
              );
            });
          } else {
            children.add(
              TextSpan(
                text: m[0],
                style: matchedItem?.style ?? style,
              ),
            );
          }
        } else {
          children.addAll([
            TextSpan(text: startChar, style: matchedItem?.regixCharStyle),
            TextSpan(
              text: mainText,
              style: matchedItem?.style ?? style,
            ),
            TextSpan(text: endChar, style: matchedItem?.regixCharStyle),
          ]);
        }
        final resultMatchIndex = matchValueIndex(m);
        if (resultMatchIndex != null && onMatchIndex != null) {
          matchIndex.add(resultMatchIndex);
          onMatchIndex!(matchIndex);
        }

        return (onMatch(List<String>.unmodifiable(matches)) ?? '');
      },
    );

    _lastValue = text;
    return TextSpan(style: style, children: children);
  }

  Map<String, List<int>>? matchValueIndex(Match match) {
    final matchValue = match[0]?.replaceFirstMapped('#', (match) => '');
    if (matchValue != null) {
      final firstMatchChar = match.start + 1;
      final lastMatchChar = match.end - 1;
      final compactMatch = {
        matchValue: [firstMatchChar, lastMatchChar]
      };
      return compactMatch;
    }
    return null;
  }
}
