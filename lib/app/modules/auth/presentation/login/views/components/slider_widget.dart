import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class RoleSliderWidget extends StatefulWidget {
  final PageController pageController;

  const RoleSliderWidget({super.key, required this.pageController});

  @override
  State<RoleSliderWidget> createState() => _RoleSliderWidgetState();
}

class _RoleSliderWidgetState extends State<RoleSliderWidget> {
  late final PageController _controller;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.pageController;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_isPaused && _controller.hasClients) {
        int nextPage = _controller.page!.round() + 1;
        if (nextPage > 2) nextPage = 0;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: SmallCurveClipper(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsLight.mainColorDark,
                  AppColorsLight.mainColorLight,
                  Color.fromARGB(255, 183, 30, 35),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                Assets.images.tsflogo.path,
                height: 70,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    setState(() => _isPaused = true);
                    _timer?.cancel();
                  },
                  onLongPressEnd: (_) {
                    setState(() => _isPaused = false);
                    _startTimer();
                  },
                  child: PageView(
                    controller: widget.pageController,
                    children: const [
                      _SliderContent(
                        title: 'Drivers',
                        description:
                            'Drive the future of transportaion.\n Start your journey with us',
                        icons: [
                          _SlideIcon(
                              icon: FontAwesomeIcons.sackDollar,
                              label: 'Weekly Pay'),
                          _SlideIcon(
                              icon: Icons.support_agent, label: '24/7 Support'),
                          _SlideIcon(
                              icon: Icons.timelapse,
                              label: 'Flexible Schedules'),
                        ],
                      ),
                      _SliderContent(
                        title: 'Owner Operator',
                        description:
                            'Take charge of your career, drive your own truck, and earn more',
                        icons: [
                          _SlideIcon(
                              icon: Icons.business_center,
                              label: 'Full Freedom'),
                          _SlideIcon(
                              icon: Icons.document_scanner,
                              label: 'Quick Settlements'),
                          _SlideIcon(
                              icon: Icons.location_pin,
                              label: 'Nationwide Loads'),
                        ],
                      ),
                      _SliderContent(
                        title: 'Partners',
                        description:
                            "Expand your business.\n Let's put your trucks to work.",
                        icons: [
                          _SlideIcon(
                              icon: Icons.edit_document,
                              label: 'Transparent Terms'),
                          _SlideIcon(
                              icon: FontAwesomeIcons.coins,
                              label: 'Better Returns'),
                          _SlideIcon(
                              icon: FontAwesomeIcons.mapLocation,
                              label: 'Track Everything'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: widget.pageController,
                count: 3,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                ),
              ),
              // addVerticalSpace(16),
              // // Play/Pause Button
              // IconButton(
              //   icon: Icon(
              //     _isPaused ? Icons.play_arrow : Icons.pause,
              //     color: Colors.white,
              //   ),
              //   onPressed: _togglePause,
              // ),
              addVerticalSpace(Get.height * 0.06),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderContent extends StatelessWidget {
  final String title;
  final String description;
  final List<_SlideIcon> icons;

  const _SliderContent({
    required this.title,
    required this.description,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: icons,
        ),
      ],
    );
  }
}

class _SlideIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SlideIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FaIcon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SmallCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
