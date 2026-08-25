import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Entrance styles for the main screen, picked per-navigation via
/// [CircularRevealTransition.argKey].
enum MainEntrance { reveal, fade }

/// GetX [CustomTransition] for the main screen. Attach as a
/// [GetPage] `customTransition` and leave `transition` unset (GetX only uses a
/// [CustomTransition] then). Pick the style with
/// `arguments: {CircularRevealTransition.argKey: MainEntrance.reveal}`.
///
/// The reveal runs on its own forward-only controller, not the route
/// `animation` — which GetX can briefly reverse during an `offAll` replace,
/// making the circle visibly revert.
class CircularRevealTransition implements CustomTransition {
  const CircularRevealTransition({
    this.origin = const Alignment(0, 0.85),
    this.curve = Curves.easeInOutCubic,
  });

  /// Route-argument key whose value (a [MainEntrance]) picks the entrance style.
  static const String argKey = 'mainEntrance';

  /// Optional route-argument key whose value (an [Alignment]) overrides the
  /// reveal [origin] for a single navigation — e.g. splash passes
  /// `Alignment.center`. Falls back to [origin] when absent.
  static const String originKey = 'mainEntranceOrigin';

  /// Origin of the [MainEntrance.reveal] circle, in alignment space
  /// (`-1..1` per axis). Defaults to near the bottom-center (the Sign-in
  /// button).
  final Alignment origin;

  /// Easing applied to the reveal radius.
  final Curve curve;

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? routeCurve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final entrance = (args is Map && args[argKey] is MainEntrance)
        ? args[argKey] as MainEntrance
        : MainEntrance.fade;
    final resolvedOrigin = (args is Map && args[originKey] is Alignment)
        ? args[originKey] as Alignment
        : origin;

    final duration = ModalRoute.of(context)?.transitionDuration ??
        const Duration(milliseconds: 450);

    switch (entrance) {
      case MainEntrance.reveal:
        return _CircularReveal(
          origin: resolvedOrigin,
          curve: curve,
          duration: duration,
          child: child,
        );
      case MainEntrance.fade:
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
    }
  }
}

/// Base for entrance widgets that play a single forward animation on mount,
/// independent of any route animation so they can never reverse.
abstract class _OneShotEntrance extends StatefulWidget {
  const _OneShotEntrance({required this.child, required this.duration});

  final Widget child;
  final Duration duration;
}

abstract class _OneShotEntranceState<T extends _OneShotEntrance>
    extends State<T> with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(vsync: this, duration: widget.duration)..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// [MainEntrance.reveal]: an expanding circular clip from [origin].
class _CircularReveal extends _OneShotEntrance {
  const _CircularReveal({
    required super.child,
    required super.duration,
    required this.origin,
    required this.curve,
  });

  final Alignment origin;
  final Curve curve;

  @override
  State<_CircularReveal> createState() => _CircularRevealState();
}

class _CircularRevealState extends _OneShotEntranceState<_CircularReveal> {
  late final Animation<double> _reveal =
      CurvedAnimation(parent: controller, curve: widget.curve);

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary caches the page so each frame only re-clips a texture
    // instead of repainting the whole tree.
    return AnimatedBuilder(
      animation: _reveal,
      child: RepaintBoundary(child: widget.child),
      builder: (context, innerChild) => ClipPath(
        clipper: _CircleRevealClipper(
          fraction: _reveal.value,
          origin: widget.origin,
        ),
        child: innerChild,
      ),
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  _CircleRevealClipper({required this.fraction, required this.origin});

  final double fraction;
  final Alignment origin;

  @override
  Path getClip(Size size) {
    final center = origin.alongSize(size);
    final maxRadius = _farthestCorner(center, size);
    return Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: maxRadius * fraction),
      );
  }

  /// Distance from [c] to the farthest corner — the radius needed to cover
  /// the whole screen.
  double _farthestCorner(Offset c, Size s) {
    final dx = math.max(c.dx, s.width - c.dx);
    final dy = math.max(c.dy, s.height - c.dy);
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldReclip(_CircleRevealClipper old) =>
      old.fraction != fraction || old.origin != origin;
}
