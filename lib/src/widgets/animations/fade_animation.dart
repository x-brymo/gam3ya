// widgets/animations/fade_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double? begin;
  final double? end;
  final Offset? offset;

  const FadeAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.begin = 0.0,
    this.end = 1.0,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget animatedWidget = child.animate()
      .fadeIn(
        begin: begin!,
        //end: end!,
        duration: duration,
        delay: delay,
        curve: Curves.easeOut,
      );
    
    if (offset != null) {
      animatedWidget = child.animate()
        .fadeIn(
          begin: begin!,
          //end: end!,
          duration: duration,
          delay: delay,
          curve: Curves.easeOut,
        )
        .move(
          begin: offset!,
          end: Offset.zero,
          duration: duration,
          delay: delay,
          curve: Curves.easeOut,
        );
    }
    
    return animatedWidget;
  }
}