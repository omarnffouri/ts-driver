import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/theme_extensions.dart';

/// A label + right-aligned value row: the label sits left, the value fills the
/// remaining width right-aligned and ellipsised. Shared by the settlement
/// detail rows and the appointment card.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.placeholder = 'N/A',
  });

  final String label;
  final String? value;

  /// Defaults to [BuildContext.secondaryTextColor] when null.
  final Color? valueColor;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Text(
          label,
          style: textStyle?.copyWith(color: context.secondaryTextColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            value == null || value!.isEmpty ? placeholder : value!,
            style: textStyle?.copyWith(
              color: valueColor ?? context.secondaryTextColor,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
