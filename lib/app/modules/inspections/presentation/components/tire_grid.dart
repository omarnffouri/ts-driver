import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../theme/theme_extensions.dart';
import '../../domain/entities/tire.dart';
import '../../domain/entities/tire_layout.dart';
import '../widgets/tire_cell.dart';

/// Renders a [TireLayout] as labelled axle rows: a left and right group of
/// stacked [TireCell]s joined by a thin axle connector. Works for single-tire
/// axles (trailer) and dual-tire axles (truck) alike. Tires are resolved from
/// [tires] by each slot's index; [onTap] receives the flat index into
/// [TireLayout.slots].
class TireGrid extends StatelessWidget {
  const TireGrid({
    super.key,
    required this.layout,
    required this.tires,
    required this.onTap,
  });

  final TireLayout layout;
  final List<Rx<Tire>> tires;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var flat = 0;
    for (var a = 0; a < layout.axles.length; a++) {
      final axle = layout.axles[a];
      final leftStart = flat;
      flat += axle.left.length;
      final rightStart = flat;
      flat += axle.right.length;
      if (a > 0) rows.add(SizedBox(height: 18.h));
      rows.add(_axle(context, axle, leftStart, rightStart));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _axle(
    BuildContext context,
    AxleConfig axle,
    int leftStart,
    int rightStart,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 6.h),
          child: AppText(
            text: axle.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: context.secondaryTextColor,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _sideColumn(context, axle.left, leftStart)),
            _connector(context),
            Expanded(child: _sideColumn(context, axle.right, rightStart)),
          ],
        ),
      ],
    );
  }

  Widget _sideColumn(BuildContext context, List<TireSlot> slots, int start) {
    final cells = <Widget>[];
    for (var i = 0; i < slots.length; i++) {
      if (i > 0) cells.add(SizedBox(height: 10.h));
      final index = start + i;
      cells.add(
        TireCell(
          tire: tires[slots[i].tireIndex],
          label: _shortLabel(slots[i]),
          onTap: () => onTap(index),
        ),
      );
    }
    return Column(children: cells);
  }

  Widget _connector(BuildContext context) {
    return SizedBox(
      width: 40.w,
      child: Row(
        children: [
          Expanded(
              child: Container(height: 1.5.h, color: context.dividerColor)),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.dividerColor,
            ),
          ),
          Expanded(
              child: Container(height: 1.5.h, color: context.dividerColor)),
        ],
      ),
    );
  }
}

/// Short cell label derived from a slot's structure: "L"/"R" for singles,
/// "L · OUT"/"L · IN" (etc.) for duals.
String _shortLabel(TireSlot slot) {
  final side = slot.side == AxleSide.left ? 'L' : 'R';
  if (!slot.isDual) return side;
  return '$side · ${slot.isInner ? 'IN' : 'OUT'}';
}
