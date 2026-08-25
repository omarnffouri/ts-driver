import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/data/connection/timeout_http_client.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/base_screen.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:upgrader/upgrader.dart';
import '../controllers/main_screen_controller.dart';

class MainScreenView extends GetView<MainScreenController> {
  const MainScreenView({super.key});

  static final _upgrader = Upgrader(
    client: TimeoutHttpClient(timeout: const Duration(seconds: 5)),
    durationUntilAlertAgain: const Duration(milliseconds: 500),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final canDismissUpdate = !ApiConstants.isProduction;

    return _RouteRevealGate(
      onRevealed: controller.markEntered,
      child: UpgradeAlert(
        upgrader: _upgrader,
        showIgnore: canDismissUpdate,
        showLater: canDismissUpdate,
        dialogStyle: UpgradeDialogStyle.cupertino,
        cupertinoButtonTextStyle: const TextStyle(
          color: kMainColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        child: _buildBody(context, primaryColor),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color primaryColor) {
    return Obx(
      () => Scaffold(
        backgroundColor: primaryColor,
        body: DoubleBack(
          onFirstBackPress: (ctx) {
            CommonWidgets.showSnackBar(
              title: '',
              message: 'Press back again to exit',
            );
          },
          textStyle: TextStyle(fontSize: 16.sp, color: kWhiteColor),
          backgroundRadius: 20.r,
          child: AppRedHeader(
            child: SafeArea(
              bottom: false,
              child: BaseScreen(
                child: PersistentTabView(
                  controller: controller.tabController.value,
                  navBarBuilder: (NavBarConfig navBarConfig) {
                    return Style8BottomNavBar(
                      navBarConfig: navBarConfig,
                      navBarDecoration: NavBarDecoration(
                        color: context.cardColor,
                        border: Border(
                          top: BorderSide(color: context.dividerColor),
                        ),
                        boxShadow: context.isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  spreadRadius: 0.2,
                                  blurRadius: 6,
                                  offset: const Offset(0, -6),
                                )
                              ],
                      ),
                    );
                  },
                  tabs: controller.getTabs(),
                  screenTransitionAnimation: const ScreenTransitionAnimation(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Invokes [onRevealed] once the page's route transition finishes — or
/// immediately if there's none — so the screen can defer first-load work.
class _RouteRevealGate extends StatefulWidget {
  const _RouteRevealGate({required this.onRevealed, required this.child});

  final VoidCallback onRevealed;
  final Widget child;

  @override
  State<_RouteRevealGate> createState() => _RouteRevealGateState();
}

class _RouteRevealGateState extends State<_RouteRevealGate> {
  Animation<double>? _animation;
  bool _fired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation == _animation) return;
    _animation?.removeStatusListener(_onStatus);
    _animation = animation;

    if (animation == null || animation.status == AnimationStatus.completed) {
      _fire();
    } else {
      animation.addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _fire();
  }

  void _fire() {
    if (_fired) return;
    _fired = true;
    widget.onRevealed();
  }

  @override
  void dispose() {
    _animation?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
