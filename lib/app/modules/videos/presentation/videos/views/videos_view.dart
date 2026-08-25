import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controllers/videos_controller.dart';
import 'components/completed_group.dart';
import 'components/continue_hero_card.dart';
import 'components/lesson_card.dart';
import 'components/training_empty.dart';
import 'components/training_progress_strip.dart';
import 'components/training_skeleton.dart';
import 'components/video_appbar.dart';

class VideosView extends GetView<VideosController> {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            const VideoAppbar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const TrainingSkeleton();
                }
                final hasVideos = controller.videos.isNotEmpty;
                return AnimationLimiter(
                  child: SmartRefresher(
                    controller: controller.refreshController,
                    header: const WaterDropMaterialHeader(
                      color: Colors.white,
                      backgroundColor: AppColors.primary,
                    ),
                    onRefresh: controller.onRefresh,
                    child: hasVideos ? _content(context) : _emptyScroll(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final sections = controller.partitionLessons();
    final current = sections.current;
    final upNext = sections.upNext;
    final completed = sections.completed;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: current == null
              ? CourseCompleteCard(total: controller.totalCount)
              : const TrainingProgressStrip(),
        ),
        if (current != null)
          SliverToBoxAdapter(
            child: ContinueHeroCard(
              index: current,
              video: controller.videos[current],
            ),
          ),
        if (upNext.isNotEmpty)
          SliverToBoxAdapter(child: _sectionLabel(context, 'Up next')),
        if (upNext.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final index = upNext[i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 375),
                    delay: const Duration(milliseconds: 60),
                    child: SlideAnimation(
                      verticalOffset: 24,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: LessonCard(
                            index: index,
                            video: controller.videos[index],
                            state: controller.stateOf(index),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: upNext.length,
              ),
            ),
          ),
        if (completed.isNotEmpty)
          SliverToBoxAdapter(child: CompletedGroup(indices: completed)),
        SliverToBoxAdapter(child: addVerticalSpace(28.h)),
      ],
    );
  }

  Widget _emptyScroll() {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(hasScrollBody: false, child: TrainingEmpty()),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
      child: AppText(
        text: text,
        size: 15,
        weight: FontWeight.w700,
        color: context.primaryTextColor,
      ),
    );
  }
}
