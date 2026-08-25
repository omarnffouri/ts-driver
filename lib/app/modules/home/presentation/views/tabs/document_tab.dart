import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/count_icon_badge.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

class DocumentTab extends GetView<HomeController> {
  const DocumentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.pendingDocumentsCount;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: controller.isLoading
            ? const _DocumentLoadingView()
            : count == 0
                ? const _NoDocumentsView()
                : _PendingDocumentsView(count: count),
      );
    });
  }
}

class _PendingDocumentsView extends GetView<HomeController> {
  const _PendingDocumentsView({required this.count});

  final int count;

  Future<void> _openDocuments() async {
    await Get.toNamed(Routes.DOCUMENTS);
    controller.refreshHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openDocuments,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            children: [
              CountIconBadge(
                icon: Icons.description_outlined,
                count: count,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: 'Document requests',
                      size: 15,
                      weight: FontWeight.w700,
                      color: context.primaryTextColor,
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      text: count == 1
                          ? '1 document needs to be uploaded'
                          : '$count documents need to be uploaded',
                      size: 12.5,
                      maxLines: 2,
                      color: context.secondaryTextColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: context.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoDocumentsView extends StatelessWidget {
  const _NoDocumentsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.primaryTint,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: AppColors.primary,
              size: 26.w,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: "You're all caught up",
                  size: 15,
                  weight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: 'No documents to upload',
                  size: 12.5,
                  color: context.secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentLoadingView extends StatelessWidget {
  const _DocumentLoadingView();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBaseColor,
      highlightColor: context.shimmerHighlightColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bar(width: 150.w, height: 13.h),
                  SizedBox(height: 8.h),
                  _bar(width: 210.w, height: 11.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
