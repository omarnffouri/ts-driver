import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppText extends StatelessWidget {
  const AppText(
      {Key? key,
      required this.text,
      this.color,
      this.weight = FontWeight.normal,
      this.size = 18,
      this.maxLines = 20,
      this.height,
      this.style,
      this.textAlign})
      : super(key: key);

  final String text;
  final Color? color;
  final FontWeight weight;
  final double size;
  final int maxLines;
  final double? height;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: style ??
          TextStyle(
            color: color,
            height: height,
            fontSize: size.sp,
            fontWeight: weight,
          ),
    );
  }
}
