library readmore;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/emoji_helper.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

enum TrimMode {
  // ignore: constant_identifier_names
  Length,
  // ignore: constant_identifier_names
  Line,
}

class ReadMoreText extends StatefulWidget {
  const ReadMoreText(
    this.data, {
    Key? key,
    this.preDataText,
    this.postDataText,
    this.preDataTextStyle,
    this.postDataTextStyle,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.Length,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = '$_kEllipsis ',
    this.delimiterStyle,
    this.callback,
    this.groupName,
    required this.messageSenderId,
    this.mention,
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  /// Textspan used before the data any heading or somthing
  final String? preDataText;

  /// group name
  final String? groupName;

  /// message sender id
  final int messageSenderId;

  /// mentions list
  final List<ConversationMentionEntity>? mention;

  /// Textspan used after the data end or before the more/less
  final String? postDataText;

  /// Textspan used before the data any heading or somthing
  final TextStyle? preDataTextStyle;

  /// Textspan used after the data end or before the more/less
  final TextStyle? postDataTextStyle;

  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final String delimiter;
  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextStyle? delimiterStyle;

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor = TextScaler.linear(widget.textScaleFactor ?? 1.0);
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText =
        widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final defaultLessStyle = widget.lessStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);
    final defaultMoreStyle = widget.moreStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);
    final defaultDelimiterStyle = widget.delimiterStyle ?? effectiveTextStyle;

    TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? defaultMoreStyle : defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    TextSpan delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
              ? widget.delimiter
              : ''
          : '',
      style: defaultDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        TextSpan? preTextSpan;
        TextSpan? postTextSpan;
        if (widget.preDataText != null) {
          preTextSpan = TextSpan(
            text: "${widget.preDataText!} ",
            style: widget.preDataTextStyle ?? effectiveTextStyle,
          );
        }
        if (widget.postDataText != null) {
          postTextSpan = TextSpan(
            text: " ${widget.postDataText!}",
            style: widget.postDataTextStyle ?? effectiveTextStyle,
          );
        }

        // Create a TextSpan with data
        final text = EmojiHelper.containsEmoji(widget.data)
            ? _buildTextSpansWithEmoji(
                _replaceUserMentions(widget.data, effectiveTextStyle),
                effectiveTextStyle,
                preTextSpan,
                postTextSpan)
            : TextSpan(
                children: [
                  if (preTextSpan != null) preTextSpan,
                  _replaceUserMentions(widget.data, effectiveTextStyle),
                  if (postTextSpan != null) postTextSpan
                ],
              );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaler: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl
                ? readMoreSize
                : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.Length:
            if (widget.trimLength < widget.data.length) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _readMore
                    ? _buildTextSpansWithEmoji(
                            _replaceUserMentions(
                                widget.data.substring(0, widget.trimLength),
                                effectiveTextStyle),
                            effectiveTextStyle,
                            preTextSpan,
                            postTextSpan)
                        .text
                    : widget.data,
                children: <TextSpan>[delimiter, link],
              );
            } else {
              textSpan = _buildTextSpansWithEmoji(
                  _replaceUserMentions(
                      widget.data.substring(0, widget.trimLength),
                      effectiveTextStyle),
                  effectiveTextStyle,
                  preTextSpan,
                  postTextSpan);
            }
            break;
          case TrimMode.Line:
            if (textPainter.didExceedMaxLines) {
              textSpan = _readMore
                  ? TextSpan(
                      style: effectiveTextStyle,
                      children: <TextSpan>[
                        _buildTextSpansWithEmoji(
                            _replaceUserMentions(
                                widget.data.substring(0, endIndex) +
                                    (linkLongerThanLine ? _kLineSeparator : ''),
                                effectiveTextStyle),
                            effectiveTextStyle,
                            preTextSpan,
                            postTextSpan),
                        delimiter,
                        link
                      ],
                    )
                  : TextSpan(
                      children: <TextSpan>[
                        _buildTextSpansWithEmoji(
                            _replaceUserMentions(
                                widget.data, effectiveTextStyle),
                            effectiveTextStyle,
                            preTextSpan,
                            postTextSpan),
                        delimiter,
                        link
                      ],
                    );
            } else {
              textSpan = _buildTextSpansWithEmoji(
                  _replaceUserMentions(widget.data, effectiveTextStyle),
                  effectiveTextStyle,
                  preTextSpan,
                  postTextSpan);
            }
            break;
        }

        return Text.rich(
          TextSpan(
            children: [
              if (preTextSpan != null) preTextSpan,
              textSpan,
              if (postTextSpan != null) postTextSpan,
            ],
          ),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.clip,
          textScaler: textScaleFactor,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return result;
  }

  TextSpan _buildTextSpansWithEmoji(
      TextSpan textSpans,
      TextStyle? effectiveTextStyle,
      TextSpan? preTextSpan,
      TextSpan? postTextSpan) {
    //
    List<TextSpan> spans = [
      if (preTextSpan != null) preTextSpan,
    ];

    textSpans.children?.forEach((element) {
      if (EmojiHelper.isEmoji(element.toPlainText())) {
        spans.add(TextSpan(
            text: element.toPlainText(),
            style: element.style?.copyWith(fontSize: 40)));
      } else {
        for (int rune in element.toPlainText().runes) {
          var character = String.fromCharCode(rune);
          if (EmojiHelper.isEmoji(character)) {
            spans.add(TextSpan(
              text: character,
              style: element.style?.copyWith(fontSize: 24),
            ));
          } else {
            spans.add(TextSpan(text: character, style: element.style));
          }
        }
      }
    });
    if (postTextSpan != null) {
      spans.add(postTextSpan);
    }

    return TextSpan(children: spans);
  }

  TextSpan _replaceUserMentions(String text, TextStyle? effectiveTextStyle) {
    RegExp userIdRegex = RegExp(r'\[~(\d+)\]');
    Iterable<Match> matches = userIdRegex.allMatches(text);

    final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

    List<InlineSpan> spans = [];

    int lastIndex = 0;
    for (Match match in matches) {
      // Add text before the mention and also call a bold text spans function
      spans.addAll(_makeBoldTextSpansBetweenStars(
                  text.substring(lastIndex, match.start), effectiveTextStyle)
              .children ??
          []);

      int userId = int.parse(match.group(1)!); // Extract user id from the match
      ConversationMentionEntity? user;

      try {
        user =
            widget.mention?.firstWhere((user) => user.participantId == userId);
      } catch (_) {}

      // Replace [~userId] with the user name
      if (user != null) {
        if (user.id?.toString() != myId) {
          spans.add(TextSpan(
            text: widget.groupName ?? "Unknown",
            style: effectiveTextStyle?.copyWith(color: AppColors.info),
          ));
        } else {
          spans.add(TextSpan(
            text: user.user?.name ?? "Unknown",
            style: effectiveTextStyle?.copyWith(color: AppColors.info),
          ));
        }
      }

      lastIndex = match.end;
    }

    // Add the remaining text after the last mention and also call a bold text spans function
    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex);
      spans.addAll(
          _makeBoldTextSpansBetweenStars(remainingText, effectiveTextStyle)
                  .children ??
              []);
    }

    return TextSpan(children: spans);
  }

  TextSpan _makeBoldTextSpansBetweenStars(
      String text, TextStyle? effectiveTextStyle) {
    /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Bullet list regex ///////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    List<TextSpan> bulletChildren = [];

    // Define the bullet-point regex pattern to match lines beginning with "* "
    final bulletRegex = RegExp(r'^([*-] )(.*)', multiLine: true);

    // Split the text into spans based on bullet lines
    text.splitMapJoin(
      bulletRegex,
      onNonMatch: (String span) {
        bulletChildren.add(TextSpan(text: span, style: effectiveTextStyle));
        return span.toString();
      },
      onMatch: (Match m) {
        final bulletContent = m.group(2) ?? '';

        // Add the bullet point as a TextSpan without altering the controller text
        bulletChildren.addAll([
          TextSpan(
              text: '   • ',
              style: effectiveTextStyle?.copyWith(fontWeight: FontWeight.bold)),
          TextSpan(text: bulletContent, style: effectiveTextStyle),
        ]);

        return '';
      },
    );

    final bulletText = TextSpan(children: bulletChildren).toPlainText();

    /////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Numbered list regex ///////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    List<TextSpan> numberedChildren = [];

    // Define the number-point regex pattern to match lines beginning with "number"
    final numberedRegex = RegExp(r'^(\d+\. )(.*)', multiLine: true);

    // Split the text into spans based on numbered lines
    bulletText.splitMapJoin(
      numberedRegex,
      onNonMatch: (String span) {
        numberedChildren.add(TextSpan(text: span, style: effectiveTextStyle));
        return span.toString();
      },
      onMatch: (Match m) {
        // Ordered list match (e.g., "1. ", "2. ")
        final orderedPrefix = m.group(1) ?? '';
        final orderedContent = m.group(2) ?? '';
        numberedChildren.addAll([
          TextSpan(
              text: "   $orderedPrefix",
              style: effectiveTextStyle?.copyWith(fontWeight: FontWeight.bold)),
          TextSpan(text: orderedContent, style: effectiveTextStyle),
        ]);

        return '';
      },
    );

    final numberedText = TextSpan(children: numberedChildren).toPlainText();

    /////////////////////////////////////////////////////////////////////////////
    /////////////////// Remaining regex combination /////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    List<TextSpan> children = [];

    String regItemText = '';

    //
    // building regix text
    for (_RichMatchItem target in regixItems) {
      regItemText =
          '${regItemText.isNotEmpty ? '$regItemText|' : regItemText}${target.regex.pattern}';
    }
    // combined regex!
    RegExp allRegex = RegExp(regItemText);

    numberedText.splitMapJoin(
      allRegex,
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: effectiveTextStyle));
        return span.toString();
      },
      onMatch: (Match m) {
        //
        final _RichMatchItem? matchedItem = regixItems.firstWhereOrNull((e) {
          return (e.regex.allMatches(m[0]!).isNotEmpty);
        });

        children.add(
          TextSpan(
            text: m.group(1) ?? m.group(2) ?? m.group(3) ?? m.group(4),
            style: effectiveTextStyle?.copyWith(
              decoration: matchedItem?.style.decoration,
              fontStyle: matchedItem?.style.fontStyle,
              fontWeight: matchedItem?.style.fontWeight,
            ),
          ),
        );

        return m[0] ?? "";
      },
    );
    return TextSpan(children: children);
  }

  final regixItems = [
    //
    // bold + italic
    _RichMatchItem(
      regex: RegExp(r'\*_(.*?)_\*'),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    ),

    //
    //
    // bold regix
    _RichMatchItem(
      regex: RegExp(r'\*(.*?)\*'),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    //
    //
    // italic regix
    _RichMatchItem(
      regex: RegExp(r'_(.*?)_'),
      style: const TextStyle(
        fontStyle: FontStyle.italic,
      ),
    ),

    //
    //
    // strike through regix
    _RichMatchItem(
      regex: RegExp(r'~(.*?)~'),
      style: const TextStyle(
        decoration: TextDecoration.lineThrough,
      ),
    ),

    //
    //
    // underline regix
    // _RichMatchItem(
    //   regex: RegExp(r'<([^>]+)>'),
    //   style: const TextStyle(
    //     decoration: TextDecoration.underline,
    //   ),
    // ),
  ];
}

class _RichMatchItem {
  final RegExp regex;
  final TextStyle style;

  _RichMatchItem({
    required this.regex,
    required this.style,
  });
}
