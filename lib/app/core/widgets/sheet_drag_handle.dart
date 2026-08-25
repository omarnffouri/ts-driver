import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../helpers/extensions.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: context.hintColor.applyOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
