import 'package:flutter/material.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

class RoundedBorderButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color labelColor;
  final Color borderColor;

  const RoundedBorderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.labelColor = AppColorsLight.mainColor,
    this.borderColor = AppColorsLight.mainColor,
  });
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
                side: BorderSide(
                  color: borderColor,
                  width: 0.5,
                ),
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
