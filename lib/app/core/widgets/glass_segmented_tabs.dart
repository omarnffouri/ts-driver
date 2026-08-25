import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/fonts.gen.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_extensions.dart';
import 'app_text.dart';

/// A themed segmented tab control built on [TabBar]; colors come from the
/// `context.segmented*` tokens in [ContextColorExtensions].
///
/// Presentation only — [value] and [onChanged] are owned by the caller. The
/// internal [TabController] is the indicator's source of truth (so the pill
/// animates immediately on tap); it re-syncs when [value] changes externally,
/// which lets the caller defer the heavier content swap.
class GlassSegmentedTabs<T> extends StatefulWidget {
  const GlassSegmentedTabs({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.badgeBuilder,
    this.disabled = false,
    this.height = 45,
  });

  final T value;
  final Map<T, String> segments;
  final ValueChanged<T> onChanged;

  /// Optional trailing widget rendered after a segment's label (e.g. an unread
  /// count badge — see [SegmentedTabBadge]). `selected` comes from the internal
  /// [TabController], so it follows taps immediately even when the caller
  /// defers the [value] swap.
  final Widget Function(T key, bool selected)? badgeBuilder;

  final bool disabled;
  final double height;

  @override
  State<GlassSegmentedTabs<T>> createState() => _GlassSegmentedTabsState<T>();
}

class _GlassSegmentedTabsState<T> extends State<GlassSegmentedTabs<T>>
    with SingleTickerProviderStateMixin {
  late final List<T> _keys = widget.segments.keys.toList(growable: false);
  late final TabController _tab = TabController(
    length: _keys.length,
    initialIndex: _indexOf(widget.value),
    vsync: this,
  );

  int _indexOf(T value) {
    final i = _keys.indexOf(value);
    return i < 0 ? 0 : i;
  }

  @override
  void didUpdateWidget(covariant GlassSegmentedTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only react to external selection changes — a tap already moved the
    // controller, so we must not animate it back while the caller catches up.
    if (oldWidget.value != widget.value) {
      _tab.animateTo(_indexOf(widget.value));
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.disabled,
      child: Container(
        height: widget.height.h,
        decoration: BoxDecoration(
          color: context.segmentedTrackColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: context.segmentedTrackBorderColor),
        ),
        // Rebuild on TabController changes so badges follow the live selection.
        child: AnimatedBuilder(
          animation: _tab,
          builder: (context, _) => TabBar(
            controller: _tab,
            onTap: (i) => widget.onChanged(_keys[i]),
            dividerHeight: 0,
            labelPadding: EdgeInsets.zero,
            splashBorderRadius: BorderRadius.circular(14.r),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: context.segmentedSelectedColor,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: context.segmentedSelectedShadow,
            ),
            labelColor: context.segmentedSelectedLabelColor,
            unselectedLabelColor: context.segmentedUnselectedLabelColor,
            labelStyle: TextStyle(
              fontFamily: FontFamily.poppins,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: FontFamily.poppins,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              for (var i = 0; i < _keys.length; i++)
                Tab(
                  height: 40.h,
                  child: widget.badgeBuilder == null
                      ? Text(
                          widget.segments[_keys[i]]!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.segments[_keys[i]]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            widget.badgeBuilder!(_keys[i], i == _tab.index),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Count/label badge for a [GlassSegmentedTabs] segment: a brand-red pill when
/// the segment is selected, a quiet count in the label grey when it isn't.
class SegmentedTabBadge extends StatelessWidget {
  const SegmentedTabBadge({
    super.key,
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      // No `alignment` here — it would make the Container expand to the tab's
      // full height and stretch the pill into a slab.
      padding: selected
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : EdgeInsets.zero,
      constraints: selected ? const BoxConstraints(minWidth: 18) : null,
      decoration: selected
          ? BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9),
            )
          : null,
      child: AppText(
        text: label,
        size: 11,
        textAlign: TextAlign.center,
        weight: FontWeight.bold,
        color: selected
            ? AppColors.onPrimary
            : context.segmentedUnselectedLabelColor,
      ),
    );
  }
}
