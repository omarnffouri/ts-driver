import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class ConversationBuzzView extends StatefulWidget {
  final double size;
  final bool inMessageView;
  const ConversationBuzzView({
    super.key,
    required this.size,
    this.inMessageView = false,
  });

  @override
  State<ConversationBuzzView> createState() => _ConversationBuzzViewState();
}

class _ConversationBuzzViewState extends State<ConversationBuzzView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<ChatDetailController>();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 75),
      vsync: this,
    );

    // Set up a vibration-like scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Set up a slight rotational animation
    _rotationAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    // Start the animation
    _controller.forward();

    // play sound
    _playBuzzSound();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.inMessageView
          ? BounceInLeft(
              duration: const Duration(milliseconds: 1000),
              from: Get.width,
              child: _buildBuzzView())
          : BounceInDown(
              duration: const Duration(milliseconds: 1000),
              from: Get.height,
              child: _buildBuzzView(),
            ),
    );
  }

  Widget _buildBuzzView() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              children: [
                if (!widget.inMessageView)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Icon(
                      Icons.electric_bolt_rounded,
                      size: widget.size,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                Icon(
                  Icons.electric_bolt_rounded,
                  size: widget.size,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playBuzzSound() async {
    try {
      await _audioPlayer
          .setAudioSource(AudioSource.asset(Assets.sounds.buzzEffect));
      await _audioPlayer.play();
      await Future.delayed(const Duration(seconds: 3)); // Play for 3 seconds
      await _audioPlayer.stop(); // Stop the sound after 3 seconds
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
