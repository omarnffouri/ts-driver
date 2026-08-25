import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/gen/fonts.gen.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import 'inspection_section.dart';

/// "NOTES" section: a single bordered text panel that, when focused, scrolls the
/// owning [scrollController] to the bottom (tracking the keyboard) so the field,
/// counter and submit button stay visible. Shared by both inspection flows.
class InspectionNotesField extends StatefulWidget {
  const InspectionNotesField({
    super.key,
    required this.controller,
    required this.scrollController,
    this.hint = 'Add any notes about the condition…',
  });

  final TextEditingController controller;
  final ScrollController scrollController;
  final String hint;

  @override
  State<InspectionNotesField> createState() => _InspectionNotesFieldState();
}

class _InspectionNotesFieldState extends State<InspectionNotesField>
    with WidgetsBindingObserver {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focus.hasFocus) _pinToBottom();
  }

  // Keyboard insets change across several frames as it animates in; pin the
  // scroll to the bottom on each so the field tracks the keyboard in lockstep.
  @override
  void didChangeMetrics() {
    if (_focus.hasFocus) _pinToBottom();
  }

  void _pinToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focus.hasFocus) return;
      final c = widget.scrollController;
      if (c.hasClients) c.jumpTo(c.position.maxScrollExtent);
    });
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InspectionSectionHeader(
          title: 'Notes',
          icon: Icons.sticky_note_2_outlined,
        ),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          maxLength: 1000,
          minLines: 4,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 14.sp,
            color: context.primaryTextColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.cardColor,
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: FontFamily.poppins,
              fontSize: 13.sp,
              color: context.hintColor,
            ),
            counterStyle: TextStyle(fontSize: 11.sp, color: context.hintColor),
            contentPadding: EdgeInsets.all(14.w),
            border: _border(context.dividerColor, 1),
            enabledBorder: _border(context.dividerColor, 1),
            focusedBorder: _border(AppColors.primary, 1.5),
          ),
        ),
      ],
    );
  }
}
