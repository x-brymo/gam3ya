// widgets/animations/pulse_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PulseAnimation extends StatelessWidget {
  final Widget child;
  final bool autoPlay;
  final bool infinite;
  final Duration duration;
  final double scale;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.autoPlay = true,
    this.infinite = false,
    this.duration = const Duration(milliseconds: 500),
    this.scale = 1.05,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var animateEffect = child.animate(
      onPlay: (controller) {
        if (infinite) {
          controller.repeat(reverse: true);
        }
      },
      autoPlay: autoPlay,
    ).scale(
      begin: Offset(0.1, 0.1),
      end: Offset(scale, scale),
      duration: duration,
      curve: Curves.easeInOut,
    );

    return animateEffect;
  }
}