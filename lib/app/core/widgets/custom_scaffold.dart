import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomScaffold extends Scaffold {
  CustomScaffold({
    Key? key,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    Widget? drawer,
    Widget? bottomNavigationBar,
    bool? resizeToAvoidBottomInset,
  }) : super(
            key: key,
            appBar: appBar,
            body: Container(
              width: double.infinity,
              height: Get.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/Background.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: body,
            ),
            floatingActionButton: floatingActionButton,
            drawer: drawer,
            bottomNavigationBar: bottomNavigationBar,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset);
}
