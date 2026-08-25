import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/sheet_drag_handle.dart';

Widget addVerticalSpace(double height) {
  return SizedBox(
    height: height,
  );
}

Widget addHorizontalSpace(double width) {
  return SizedBox(
    width: width,
  );
}

/// Theme-aware date picker. Inherits the ambient [ThemeData] (so it renders
/// dark in dark mode) with the brand-red primary that the app's color scheme
/// already defines — no forced light scheme. Defaults to a 1900–2050 range.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(1900),
    lastDate: lastDate ?? DateTime(2050),
  );
}

/// Shared modal bottom sheet shell: a [BuildContext.sheetColor] background so
/// the cards inside read as elevated, a hairline divider border so the sheet
/// reads apart from the page behind it, a rounded top, a [SheetDragHandle] drag
/// affordance, and a [SafeArea]-wrapped [child]. Colors resolve against the
/// current theme. The handle follows [enableDrag] by default (a handle signals
/// draggability); pass [showGrabber] to override that.
Future<T?> showAppBottomSheet<T>({
  required Widget child,
  double topRadius = 20.0,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showGrabber,
  BoxConstraints? constraints,
}) {
  final context = Get.context!;
  final grabber = showGrabber ?? enableDrag;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    constraints: constraints,
    backgroundColor: context.sheetColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      side: BorderSide(color: context.dividerColor),
    ),
    builder: (_) => SafeArea(
      child: grabber
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
                  child: const Center(child: SheetDragHandle()),
                ),
                Flexible(child: child),
              ],
            )
          : child,
    ),
  );
}
