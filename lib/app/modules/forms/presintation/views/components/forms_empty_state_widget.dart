import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class FormsEmptyStateWidget extends StatelessWidget {
  const FormsEmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AllSetWidget(
        title: 'No Forms',
        subTitle: 'No Forms to Show',
      ),
    );
  }
}
