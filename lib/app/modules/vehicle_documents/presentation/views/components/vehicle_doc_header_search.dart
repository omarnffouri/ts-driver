import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted search field for the red header (chat-style, white-on-red). Shows a
/// clear button only while there's text, and re-binds its listener when the
/// active tab swaps the [controller].
class VehicleDocHeaderSearch extends StatefulWidget {
  const VehicleDocHeaderSearch({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onClear,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextInputType? keyboardType;

  @override
  State<VehicleDocHeaderSearch> createState() => _VehicleDocHeaderSearchState();
}

class _VehicleDocHeaderSearchState extends State<VehicleDocHeaderSearch> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(VehicleDocHeaderSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white.withValues(alpha: .8);
    final hasText = widget.controller.text.isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: .20)),
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: 1,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        textAlignVertical: TextAlignVertical.center,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: .7)),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          icon: Icon(Icons.search, color: iconColor),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: _clear,
                  child: Icon(Icons.close_rounded, color: iconColor),
                )
              : null,
        ),
      ),
    );
  }
}
