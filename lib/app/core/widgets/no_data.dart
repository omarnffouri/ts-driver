import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class NoDataView extends StatelessWidget {
  const NoDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Center(
          child: Lottie.asset(Assets.json.noDataAnimation),
        ),
      ),
    );
  }
}
