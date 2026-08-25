import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/gen/fonts.gen.dart';
import '../../domain/entities/tire.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/widgets/app_botton.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../domain/entities/tire_layout.dart';

/// Guided per-tire editor: a single-tire identity, N-step progress dots, big
/// steppers + quick presets, and Save & Next so the driver records every tire
/// in one pass without reopening the sheet. Drives any [TireLayout.slots].
class TireEditorSheet extends StatefulWidget {
  const TireEditorSheet({
    super.key,
    required this.layout,
    required this.tires,
    required this.startIndex,
    this.onCommit,
  });

  final TireLayout layout;
  final List<Rx<Tire>> tires;
  final int startIndex;

  /// Invoked after each tire's values are written (so a controller can refresh
  /// derived state like a "has data" flag). Fires on Save & Next / Finish /
  /// Skip / dot navigation.
  final VoidCallback? onCommit;

  @override
  State<TireEditorSheet> createState() => _TireEditorSheetState();
}

class _TireEditorSheetState extends State<TireEditorSheet> {
  final TextEditingController _depthCtrl = TextEditingController();
  final TextEditingController _pressureCtrl = TextEditingController();

  late int _index = widget.startIndex;

  /// Flat, slot-ordered tire entries paired with their derived display label.
  late final List<({Rx<Tire> tire, String label})> _entries = [
    for (final axle in widget.layout.axles)
      for (final slot in [...axle.left, ...axle.right])
        (tire: widget.tires[slot.tireIndex], label: _fullLabel(axle, slot)),
  ];
  int _depth = 0;
  int _pressure = 0;

  static const _depthPresets = [32, 24, 16, 8, 4];
  static const _pressurePresets = [110, 100, 90, 80];

  @override
  void initState() {
    super.initState();
    _load(_index);
  }

  @override
  void dispose() {
    _depthCtrl.dispose();
    _pressureCtrl.dispose();
    super.dispose();
  }

  Tire get _tire => _entries[_index].tire.value;
  bool get _depthLow => _depth < Tire.minSafeDepth;
  bool get _pressureLow => _pressure < Tire.minSafePressure;
  bool get _isLast => _index == _entries.length - 1;

  void _load(int i) {
    final tire = _entries[i].tire.value;
    setState(() {
      _index = i;
      _depth = tire.depth;
      _pressure = tire.pressure;
      _depthCtrl.text = _depth.toString();
      _pressureCtrl.text = _pressure.toString();
    });
  }

  void _commit({required bool markChecked}) {
    final rx = _entries[_index].tire;
    rx.value.depth = _depth;
    rx.value.pressure = _pressure;
    if (markChecked) rx.value.checked = true;
    rx.refresh();
    widget.onCommit?.call();
  }

  void _applyDepth(int v, {bool fromField = false}) {
    final c = v.clamp(0, 32);
    setState(() => _depth = c);
    if (!fromField || c != v) _depthCtrl.text = c.toString();
  }

  void _applyPressure(int v, {bool fromField = false}) {
    final c = v.clamp(0, 150);
    setState(() => _pressure = c);
    if (!fromField || c != v) _pressureCtrl.text = c.toString();
  }

  void _saveNext() {
    _commit(markChecked: true);
    if (_isLast) {
      Get.back();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      _load(_index + 1);
    }
  }

  void _goTo(int target) {
    if (target == _index || target < 0 || target >= _entries.length) return;
    _commit(markChecked: false);
    FocusManager.instance.primaryFocus?.unfocus();
    _load(target);
  }

  void _skip() {
    if (_isLast) {
      _commit(markChecked: false);
      Get.back();
    } else {
      _goTo(_index + 1);
    }
  }

  Color _stateColor(Tire tire) => tire.isLow
      ? AppColors.primary
      : (tire.checked ? context.successTextColor : context.hintColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              SizedBox(height: 14.h),
              _progressDots(),
              SizedBox(height: 8.h),
              Divider(height: 24.h, color: context.dividerColor),
              _stepperBlock(
                label: 'Depth',
                suffix: '/32',
                value: _depth,
                fieldCtrl: _depthCtrl,
                low: _depthLow,
                presets: _depthPresets,
                onSet: _applyDepth,
              ),
              SizedBox(height: 18.h),
              _stepperBlock(
                label: 'Pressure',
                suffix: 'PSI',
                value: _pressure,
                fieldCtrl: _pressureCtrl,
                low: _pressureLow,
                presets: _pressurePresets,
                onSet: _applyPressure,
              ),
              SizedBox(height: 20.h),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        SizedBox(
          width: 42.w,
          height: 44.h,
          child: Image.asset(
            AppIcons.tireIcon,
            fit: BoxFit.contain,
            color: _stateColor(_tire),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: _entries[_index].label,
                size: 17,
                weight: FontWeight.w700,
                color: context.strongTextColor,
              ),
              SizedBox(height: 2.h),
              AppText(
                text: 'Tire ${_index + 1} of ${_entries.length}',
                size: 12,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: Get.back,
          child:
              Icon(Icons.close_rounded, size: 22.w, color: context.hintColor),
        ),
      ],
    );
  }

  Widget _progressDots() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(_entries.length, (i) {
        final tire = _entries[i].tire.value;
        final filled = tire.checked || tire.isLow;
        final color = _stateColor(tire);
        final isCurrent = i == _index;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _goTo(i),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? color : Colors.transparent,
                border: filled
                    ? null
                    : Border.all(color: context.hintColor, width: 1.2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _stepperBlock({
    required String label,
    required String suffix,
    required int value,
    required TextEditingController fieldCtrl,
    required bool low,
    required List<int> presets,
    required void Function(int, {bool fromField}) onSet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: label,
              size: 15,
              weight: FontWeight.w700,
              color: context.strongTextColor,
            ),
            SizedBox(width: 4.w),
            AppText(text: '($suffix)', size: 11, color: context.hintColor),
            const Spacer(),
            if (low)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.primaryTint,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: const AppText(
                  text: 'LOW',
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _stepBtn(Icons.remove_rounded, () => onSet(value - 1)),
            Expanded(child: _numberField(fieldCtrl, low, onSet)),
            _stepBtn(Icons.add_rounded, () => onSet(value + 1)),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: presets
              .map((p) => _presetChip(p, value == p, () => onSet(p)))
              .toList(),
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColors.onPrimary, size: 24.w),
      ),
    );
  }

  Widget _numberField(
    TextEditingController ctrl,
    bool low,
    void Function(int, {bool fromField}) onSet,
  ) {
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: c, width: w),
        );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 3,
        onChanged: (s) => onSet(int.tryParse(s) ?? 0, fromField: true),
        style: TextStyle(
          fontFamily: FontFamily.poppins,
          color: low ? AppColors.primary : context.strongTextColor,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: context.inputFillColor,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: border(context.dividerColor, 1),
          enabledBorder:
              border(low ? AppColors.primary : context.dividerColor, 1),
          focusedBorder: border(AppColors.primary, 1.5),
        ),
      ),
    );
  }

  Widget _presetChip(int value, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? context.primaryTint : context.inputFillColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : context.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: AppText(
          text: '$value',
          size: 13,
          weight: FontWeight.w700,
          color: selected ? AppColors.primary : context.primaryTextColor,
        ),
      ),
    );
  }

  Widget _actions() {
    final canSave = _depth > 0 && _pressure > 0;
    return Column(
      children: [
        Row(
          children: [
            if (_index > 0)
              _textAction(Icons.chevron_left_rounded, 'Prev',
                  context.secondaryTextColor,
                  iconLeading: true, onTap: () => _goTo(_index - 1)),
            const Spacer(),
            if (!_isLast)
              _textAction(
                  Icons.chevron_right_rounded, 'Skip', context.hintColor,
                  iconLeading: false, onTap: _skip),
          ],
        ),
        SizedBox(height: 8.h),
        AppButton(
          text: _isLast ? 'Save & Finish' : 'Save & Next',
          bgColor: AppColors.primary,
          width: double.infinity,
          hight: 52.h,
          radius: 14,
          fontWeight: FontWeight.bold,
          onPressed: canSave ? _saveNext : () {},
        ),
      ],
    );
  }

  Widget _textAction(
    IconData icon,
    String label,
    Color color, {
    required bool iconLeading,
    required VoidCallback onTap,
  }) {
    final text = AppText(
      text: label,
      size: 13,
      weight: FontWeight.w600,
      color: color,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconLeading
              ? [Icon(icon, size: 18.w, color: color), text]
              : [text, Icon(icon, size: 18.w, color: color)],
        ),
      ),
    );
  }
}

/// Full identity label derived from a slot's axle + structure, e.g.
/// "Steer · Left" or "Axle 2 · Left Outer".
String _fullLabel(AxleConfig axle, TireSlot slot) {
  final side = slot.side == AxleSide.left ? 'Left' : 'Right';
  if (!slot.isDual) return '${axle.name} · $side';
  return '${axle.name} · $side ${slot.isInner ? 'Inner' : 'Outer'}';
}
