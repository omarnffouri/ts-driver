import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/emoji_picker.dart';

/// Emoji/GIF panel; the grabber + tab bar drag to resize the slot's panelHeight.
class ResizableEmojiGifPanel extends StatefulWidget {
  const ResizableEmojiGifPanel({super.key, required this.controller});

  final ChatDetailController controller;

  @override
  State<ResizableEmojiGifPanel> createState() => _ResizableEmojiGifPanelState();
}

class _ResizableEmojiGifPanelState extends State<ResizableEmojiGifPanel>
    with TickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  double _animBegin = 0;
  double _animEnd = 0;

  double _minH = 0;
  double _maxH = 0;

  ChatDetailController get _c => widget.controller;

  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _anim.addListener(_onAnimTick);
    // expanded sheet -> keyboard: collapse to keyboard height as it rises
    _focusListener = () {
      if (_c.focusNode.value.hasFocus &&
          _c.panelHeight.value > _c.keyboardHeight.value + 1) {
        _animateTo(_c.keyboardHeight.value);
      }
    };
    _c.focusNode.value.addListener(_focusListener);
  }

  @override
  void dispose() {
    _c.focusNode.value.removeListener(_focusListener);
    _tabs.dispose();
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_anim.isAnimating) _anim.stop();
    _c.panelHeight.value =
        (_c.panelHeight.value - d.delta.dy).clamp(_minH, _maxH).toDouble();
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v > 700 && _c.panelHeight.value <= _minH + 1) {
      _c.closeKeyboardAndPicker();
      return;
    }
    final mid = (_minH + _maxH) / 2;
    final target = v < -700
        ? _maxH
        : v > 700
            ? _minH
            : (_c.panelHeight.value > mid ? _maxH : _minH);
    _animateTo(target);
  }

  void _onAnimTick() {
    _c.panelHeight.value = _animBegin + (_animEnd - _animBegin) * _curve.value;
  }

  void _animateTo(double target) {
    _animBegin = _c.panelHeight.value;
    _animEnd = target;
    _anim.forward(from: 0);
  }

  void _expandToFull() {
    if (_c.panelHeight.value < _maxH) _animateTo(_maxH);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final available =
        mq.size.height - mq.padding.top - mq.padding.bottom - 190.h;
    _maxH = math.max(96.h, available);
    _minH = math.min(math.max(220.h, _c.keyboardHeight.value), _maxH);

    return Material(
      color: context.cardColor,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewPadding.bottom),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 26.h,
                    child: Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: context.hintColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: context.hintColor,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.emoji_emotions_outlined)),
                      Tab(icon: Icon(Icons.gif_box_outlined)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: EmojiGifTabbedBody(
                tabs: _tabs,
                controller: _c,
                onGifSearchTap: _expandToFull,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
