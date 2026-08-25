import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/tenor/tenor_gif_picker.dart';

/// Emoji + GIF tab bodies, height-less so the parent panel sizes them.
class EmojiGifTabbedBody extends StatelessWidget {
  const EmojiGifTabbedBody({
    super.key,
    required this.tabs,
    required this.controller,
    required this.onGifSearchTap,
  });

  final TabController tabs;
  final ChatDetailController controller;
  final VoidCallback onGifSearchTap;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabs,
      children: [
        EmojiPicker(
          textEditingController: controller.richTextController,
          onBackspacePressed: () {},
          config: buildChatEmojiConfig(context, surface: context.cardColor),
        ),
        TenorGifPicker(
          onTap: onGifSearchTap,
          onSelected: (gif) {
            controller.closeKeyboardAndPicker();
            controller.sendGifMessage(gif);
          },
          service: controller.tenorService,
        ),
      ],
    );
  }
}

/// Shared emoji [Config] for the input panel and the reaction dialog.
Config buildChatEmojiConfig(BuildContext context, {required Color surface}) =>
    Config(
      checkPlatformCompatibility: true,
      emojiViewConfig: EmojiViewConfig(
        backgroundColor: surface,
        columns: 7,
        emojiSizeMax: 24.sp,
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        recentsLimit: 30,
        replaceEmojiOnLimitExceed: false,
        buttonMode: ButtonMode.MATERIAL,
        loadingIndicator: const SizedBox.shrink(),
        noRecents: Text(
          'No Recents',
          style: TextStyle(
              fontSize: 20.sp, color: context.hintColor.withValues(alpha: 0.5)),
          textAlign: TextAlign.center,
        ),
      ),
      categoryViewConfig: CategoryViewConfig(
        initCategory: Category.RECENT,
        backgroundColor: surface,
        indicatorColor: AppColors.primary,
        iconColor: context.hintColor,
        iconColorSelected: AppColors.primary,
        backspaceColor: AppColors.primary,
        dividerColor: context.dividerColor,
        recentTabBehavior: RecentTabBehavior.RECENT,
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const CategoryIcons(),
      ),
      searchViewConfig: SearchViewConfig(
        backgroundColor: surface,
        buttonIconColor: context.hintColor,
        hintText: 'Search',
        hintTextStyle: TextStyle(color: context.hintColor, fontSize: 14.sp),
        inputTextStyle:
            TextStyle(color: context.primaryTextColor, fontSize: 14.sp),
      ),
      bottomActionBarConfig: BottomActionBarConfig(
        enabled: true,
        showBackspaceButton: true,
        showSearchViewButton: true,
        backgroundColor: surface,
        buttonColor: Colors.transparent,
        buttonIconColor: context.hintColor,
      ),
      skinToneConfig: SkinToneConfig(
        enabled: true,
        dialogBackgroundColor: surface,
        indicatorColor: context.hintColor,
      ),
    );
