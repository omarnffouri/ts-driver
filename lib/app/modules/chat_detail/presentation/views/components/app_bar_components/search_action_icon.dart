part of '../../chat_detail_view.dart';

class _SearchMessagesActionIcon extends GetView<ChatDetailController> {
  const _SearchMessagesActionIcon();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.isSearchEnabled(!controller.isSearchEnabled.value);
        if (!controller.isSearchEnabled.value) {
          controller.clearSearch();
        }
      },
      child: Obx(
        () => Icon(
          controller.isSearchEnabled.value ? Icons.close : Icons.search,
          color: AppColors.primary,
          size: 25,
        ),
      ),
    );
  }
}
