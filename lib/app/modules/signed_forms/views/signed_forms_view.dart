import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/widgets/app_screen.dart';
import '../../../core/widgets/file_viewer.dart';
import '../../../theme/theme_extensions.dart';
import '../../forms/domain/entities/signed_form_entity.dart';
import '../controllers/signed_forms_controller.dart';
import 'bottom_sheets/signed_form_actions_sheet.dart';
import 'widgets/signed_form_card.dart';
import 'widgets/signed_form_row.dart';
import 'widgets/signed_forms_app_bar.dart';
import 'widgets/signed_forms_empty_state.dart';
import 'widgets/signed_forms_no_results.dart';
import 'widgets/signed_forms_search_bar.dart';
import 'widgets/signed_forms_section_header.dart';
import 'widgets/signed_forms_skeleton.dart';

class SignedFormsView extends GetView<SignedFormsController> {
  const SignedFormsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            const SignedFormsAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const SignedFormsSkeleton();
                }
                if (controller.signedForms.isEmpty) {
                  return const SignedFormsEmptyState();
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                      child: SizedBox(
                        height: 48.h,
                        child: Row(
                          children: [
                            const Expanded(child: SignedFormsSearchBar()),
                            SizedBox(width: 10.w),
                            const ViewToggleButton(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: _content(context)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final noResults = controller.filtered.isEmpty &&
        controller.searchController.text.isNotEmpty;
    if (noResults) {
      return const SignedFormsNoResults();
    }
    // SmartRefresher must wrap a ScrollView directly, so AnimationLimiter goes
    // above it and the CustomScrollView is its direct child.
    return AnimationLimiter(
      child: SmartRefresher(
        controller: controller.refreshController,
        header: const WaterDropMaterialHeader(),
        onRefresh: () async {
          controller.searchController.clear();
          await controller.getAllSignedForms();
          controller.refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          slivers: [
            for (final section in controller.sections) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverToBoxAdapter(
                  child: SignedFormsSectionHeader(
                    title: section.title,
                    count: section.items.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: controller.isGrid.value
                    ? _gridSliver(context, section.items)
                    : _listSliver(context, section.items),
              ),
            ],
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }

  Widget _gridSliver(BuildContext context, List<SignedFormEntity> items) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final form = items[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 3,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: SignedFormCard(
                  form: form,
                  onTap: () => _openViewer(form),
                  onMore: () => showSignedFormActions(form),
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  Widget _listSliver(BuildContext context, List<SignedFormEntity> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final form = items[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: SignedFormRow(
                    form: form,
                    onTap: () => _openViewer(form),
                    onMore: () => showSignedFormActions(form),
                  ),
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  void _openViewer(SignedFormEntity form) {
    Get.to(
      () => FileViewer(
        title: form.formName ?? '',
        path: form.signedFormUrl ?? '',
        folderName: 'forms_docs',
        fileLoaded: () {},
      ),
    );
  }
}
