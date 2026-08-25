import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import 'register_field.dart';

/// Field-styled dropdown trigger that opens a themed, searchable bottom sheet
/// picker. Matches [RegisterField]'s look and avoids the legacy shared
/// SearchableDropDown.
class RegisterDropdownField extends StatelessWidget {
  const RegisterDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.value,
    required this.onSelected,
    this.icon,
    this.isRequired = true,
    this.isLoading = false,
    this.searchHint = 'Search',
    this.sheetTitle = 'Select',
  });

  final String label;
  final String hint;
  final IconData? icon;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onSelected;
  final bool isRequired;
  final bool isLoading;
  final String searchHint;
  final String sheetTitle;

  Future<void> _openPicker() async {
    // Drop focus before opening so the field that was active isn't remembered.
    FocusManager.instance.primaryFocus?.unfocus();
    await showAppBottomSheet<void>(
      child: _DropdownPickerSheet(
        title: sheetTitle,
        searchHint: searchHint,
        icon: icon,
        options: options,
        selected: value,
        onSelected: (v) {
          onSelected(v);
          Get.back();
        },
      ),
    );
    // The modal route restores focus to the previously-focused field as it pops
    // — drop it again on the next frame so the keyboard doesn't spring back up.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(label: label, isRequired: isRequired),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: isLoading ? null : _openPicker,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: context.inputFillColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20.w, color: AppColors.mutedPrimary),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: AppText(
                    text: hasValue ? value! : hint,
                    size: 14,
                    color:
                        hasValue ? context.primaryTextColor : context.hintColor,
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.hintColor,
                    size: 22.w,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownPickerSheet extends StatefulWidget {
  const _DropdownPickerSheet({
    required this.title,
    required this.searchHint,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String title;
  final String searchHint;
  final IconData? icon;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<_DropdownPickerSheet> createState() => _DropdownPickerSheetState();
}

class _DropdownPickerSheetState extends State<_DropdownPickerSheet> {
  final _searchController = TextEditingController();
  late final List<String> _sortedAll = [...widget.options]
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  late List<String> _filtered = _sortedAll;
  bool _hasQuery = false;

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _hasQuery = q.isNotEmpty;
      _filtered = q.isEmpty
          ? _sortedAll
          : _sortedAll.where((o) => o.toLowerCase().contains(q)).toList();
    });
  }

  /// Flat list interleaving alphabetical letter headers with their options.
  List<({bool isHeader, String text})> _entries() {
    final out = <({bool isHeader, String text})>[];
    String? letter;
    for (final o in _filtered) {
      final l = o.isNotEmpty ? o[0].toUpperCase() : '#';
      if (l != letter) {
        letter = l;
        out.add((isHeader: true, text: l));
      }
      out.add((isHeader: false, text: o));
    }
    return out;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries();
    return SizedBox(
      height: 0.7.sh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.primaryTint,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child:
                        Icon(widget.icon, size: 18.w, color: AppColors.primary),
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: AppText(
                    text: widget.title,
                    size: 16,
                    weight: FontWeight.w700,
                    color: context.strongTextColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(
                fontFamily: FontFamily.poppins,
                fontSize: 14.sp,
                color: context.primaryTextColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: context.inputFillColor,
                hintText: widget.searchHint,
                hintStyle: TextStyle(
                  fontFamily: FontFamily.poppins,
                  fontSize: 13.sp,
                  color: context.hintColor,
                ),
                prefixIcon:
                    Icon(Icons.search_rounded, color: context.hintColor),
                suffixIcon: _hasQuery
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _filter('');
                        },
                        child: Icon(Icons.close_rounded,
                            color: context.hintColor, size: 20.w),
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                border: registerFieldBorder(context.dividerColor, 1),
                enabledBorder: registerFieldBorder(context.dividerColor, 1),
                focusedBorder: registerFieldBorder(AppColors.primary, 1.5),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: AppText(
                      text: 'No results',
                      size: 14,
                      color: context.hintColor,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      if (e.isHeader) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 4.h),
                          child: AppText(
                            text: e.text,
                            size: 12,
                            weight: FontWeight.w700,
                            color: context.secondaryTextColor,
                          ),
                        );
                      }
                      final selected = e.text == widget.selected;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () => widget.onSelected(e.text),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 2.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 13.h),
                          decoration: BoxDecoration(
                            color: selected
                                ? context.primaryTint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  text: e.text,
                                  size: 14,
                                  weight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: selected
                                      ? AppColors.primary
                                      : context.primaryTextColor,
                                ),
                              ),
                              if (selected)
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 20.w),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
