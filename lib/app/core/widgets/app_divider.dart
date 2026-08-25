import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    Key? key,
    this.color = Colors.grey,
    this.height = 15,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
  }) : super(key: key);

  final Color color;
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
