import 'package:flutter/material.dart';

import '../../../../theme/theme_extensions.dart';

Widget customContainer({
  required String title,
}) {
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 6,
        ),
        Text(
          title,
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(
          thickness: 1.5,
          color: context.dividerColor,
        )
      ],
    ),
  );
}
