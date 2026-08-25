part of '../../chat_detail_view.dart';

class _MessageActionIcons extends GetView<ChatDetailController> {
  const _MessageActionIcons();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: (controller.isMessageSelectionEnabled),
        child: const Row(
          children: [
            //
            // copy message button
            _CopyMessageActionIcon(),

            //
            // forward message button
            _ForwardMessageActionIcon(),

            // delete message button
            _DeleteMessageActionIcon(),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

class _CopyMessageActionIcon extends GetView<ChatDetailController> {
  const _CopyMessageActionIcon();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.selectedMessages.length == 1,
        child: GestureDetector(
          onTap: () {
            controller.copyMessage();
          },
          child: Icon(
            Icons.content_copy_rounded,
            color: context.chatAppBarIconColor,
            size: 25,
          ),
        ).marginOnly(right: 15),
      ),
    );
  }
}

/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////

class _ForwardMessageActionIcon extends GetView<ChatDetailController> {
  const _ForwardMessageActionIcon();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.selectedMessages.isNotEmpty,
        child: GestureDetector(
          onTap: () {
            controller.forwardMessage();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              Icons.reply_rounded,
              color: AppColors.primary,
              size: 25,
            ),
          ),
        ).marginOnly(right: 15),
      ),
    );
  }
}

class _DeleteMessageActionIcon extends GetView<ChatDetailController> {
  const _DeleteMessageActionIcon();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.isMessageDeletable(),
        child: GestureDetector(
          onTap: () {
            controller.deleteMessageClicked();
          },
          child: const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ).marginOnly(right: 15),
      ),
    );
  }
}
