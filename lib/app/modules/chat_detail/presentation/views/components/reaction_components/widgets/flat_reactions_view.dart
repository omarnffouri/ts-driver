import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class FlatReactionsView extends StatelessWidget {
  const FlatReactionsView({
    super.key,
    required this.reactions,
    this.maxWidth = 50,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.size = 20.0,
    this.direction = TextDirection.ltr,
    this.emojiCounterTextStyle,
  });

  // List of reactions
  final List<String> reactions;

  // Size of the reaction icon/text
  final double size;

  // max width of the reactions
  final double maxWidth;

  // Text direction (LTR or RTL)
  final TextDirection direction;

  // background colors of the reactions
  final Color backgroundColor;

  // border line color
  final Color borderColor;

  // emojies count text style
  final TextStyle? emojiCounterTextStyle;

  @override
  Widget build(BuildContext context) {
    final uniqueReactions = _getUniqueReactions();

    //
    // calculating how many reaction we can show in the space
    // where 4 is the padding of the reactions
    // where 4 is the margin of the reacions row inside a container
    int canShow = ((maxWidth - 8) / (size + 4)).floorToDouble().toInt();

    // Calculate the remaining number of reactions exceded the canShow
    int unpresentableCount = reactions.length - canShow;

    //
    // check if we have any unpresentableCount
    // then remove one show counting and add it to unpresentable counts
    if (unpresentableCount > 0) {
      canShow -= 1;
      unpresentableCount += 1;
    }
    // else means
    // now all reaction are presentable in the available space
    // then check if have duplicate reactions also add then for count
    // and remove one can show count so instead of emoji we can present a count
    else if (uniqueReactions.length < reactions.length) {
      unpresentableCount = reactions.length - uniqueReactions.length;
      if (unpresentableCount > 0) {
        canShow -= 1;
      }
    }

    //
    // reaction which finally we can present
    final reactionsToShow = uniqueReactions.length > canShow
        ? uniqueReactions.sublist(0, canShow)
        : uniqueReactions;

    // Helper function to create a reaction widget with proper styling
    Widget createReactionWidget(String reaction, int index) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        // padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 2.0),

        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Text(
              reaction,
              style: TextStyle(fontSize: size),
            ),
          ),
        ),
      );
    }

    // Build the list of reaction widgets using the helper function
    final reactionWidgets = reactionsToShow.asMap().entries.map((entry) {
      final index = entry.key;
      final reaction = entry.value;
      return createReactionWidget(reaction, index);
    }).toList();

    return reactions.isEmpty
        ? const SizedBox.shrink()
        : Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Efficiently display reactions based on direction
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: direction == TextDirection.ltr
                      ? reactionWidgets.reversed.toList()
                      : reactionWidgets,
                ),
                // Show remaining count only if there are more than 4 reactions
                if (unpresentableCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 2),
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          '+$unpresentableCount',
                          style: emojiCounterTextStyle ??
                              TextStyle(
                                fontSize: 12.sp,
                                color: context.primaryTextColor,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  List<String> _getUniqueReactions() {
    List<String> uniqueReactions = [];
    for (var element in reactions) {
      if (!uniqueReactions.contains(element)) {
        uniqueReactions.add(element);
      }
    }
    return uniqueReactions;
  }
}
