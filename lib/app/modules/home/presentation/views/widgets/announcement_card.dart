import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/annoucments/domain/entities/annoucement_entity.dart';
import 'package:ts_driver/app/modules/annoucments/presentation/controllers/annoucments_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_image_preview.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:timeago/timeago.dart' as timeago;

const _kFallbackImage =
    "https://images.pexels.com/photos/312839/pexels-photo-312839.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";

class AnnouncementCard extends GetView<HomeController> {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.index,
  });

  final AnnoucementEntity announcement;
  final int index;

  AnnoucmentsController get _ann => controller.annoucmentsController;

  void _onImageTap() {
    _ann.updateAnnoucementsReadStatus(announcement, index);
    if (announcement.image == null) return;
    Get.to(
      () => ChatImagePreview(
        title: "Announcement",
        previewImages: [PreviewImage(url: announcement.image, file: null)],
        initialIndex: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _onImageTap,
          child: ProfileImage.network(
            url: announcement.image ?? _kFallbackImage,
            radius: 10,
            width: double.infinity,
            height: Get.height * 0.20,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: timeago.format(announcement.createdAt ?? DateTime.now()),
              size: 12,
              weight: FontWeight.bold,
              color: context.hintColor,
            ),
            _ReadStatusAction(announcement: announcement, index: index),
          ],
        ),
        AppText(
          text: announcement.title ?? "",
          size: 16,
          weight: FontWeight.bold,
          color: context.primaryTextColor,
        ),
        Html(data: announcement.message ?? "", style: {
          "body": Style(color: context.primaryTextColor),
          "h2": Style(fontSize: FontSize(18.sp), fontWeight: FontWeight.bold),
          "h3": Style(fontSize: FontSize(15.sp)),
          "h4": Style(fontSize: FontSize(15.sp)),
          "p": Style(fontSize: FontSize(15.sp)),
        }),
      ],
    ).marginSymmetric(horizontal: 10, vertical: 5);
  }
}

class _ReadStatusAction extends GetView<HomeController> {
  const _ReadStatusAction({required this.announcement, required this.index});

  final AnnoucementEntity announcement;
  final int index;

  AnnoucmentsController get _ann => controller.annoucmentsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUpdatingThis =
          _ann.updatingAnnouncementStatusIndex.value == index &&
              _ann.isupdatingAnnoucementStatus;

      if (isUpdatingThis) {
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeCap: StrokeCap.round,
          ),
        ).marginOnly(right: 15);
      }

      if (announcement.read == 1) {
        return const _ReadReceipt().marginOnly(right: 10);
      }

      return GestureDetector(
        onTap: () => _ann.updateAnnoucementsReadStatus(announcement, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            "Read me",
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ).marginOnly(right: 5);
    });
  }
}

class _ReadReceipt extends StatelessWidget {
  const _ReadReceipt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          left: 4,
          child: Icon(Icons.check, size: 12, color: context.hintColor),
        ),
        Icon(Icons.check, size: 12, color: context.hintColor),
      ],
    );
  }
}
