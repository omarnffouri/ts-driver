import 'package:flutter/material.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

class RoundedFillButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color labelColor;

  const RoundedFillButton(
      {super.key,
      required this.label,
      this.labelColor = Colors.white,
      this.backgroundColor = AppColorsLight.mainColor,
      required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                // Adjust the radius as needed
              ),
              backgroundColor: backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: labelColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
