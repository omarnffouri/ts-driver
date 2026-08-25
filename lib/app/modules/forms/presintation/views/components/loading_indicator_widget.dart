import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        child: Lottie.asset(
          Assets.json.pageLoader,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
