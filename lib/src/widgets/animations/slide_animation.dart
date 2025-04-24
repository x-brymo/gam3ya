// widgets/animations/slide_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double distance;
  final bool fade;
  final AnimationController? controller;

  const SlideAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.direction = SlideDirection.fromBottom,
    this.distance = 50.0,
    this.fade = true,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Offset begin;
    
    switch (direction) {
      case SlideDirection.fromTop:
        begin = Offset(0, -distance);
        break;
      case SlideDirection.fromBottom:
        begin = Offset(0, distance);
        break;
      case SlideDirection.fromLeft:
        begin = Offset(-distance, 0);
        break;
      case SlideDirection.fromRight:
        begin = Offset(distance, 0);
        break;
    }
    
    Widget animatedWidget = child.animate(
      controller: controller
    )
      .move(
        begin: begin,
        end: Offset.zero,
        duration: duration,
        delay: delay,
        curve: Curves.easeOut,
        
      );
      
    if (fade) {
      animatedWidget = child.animate(
        controller: controller
      )
        .fadeIn(
          duration: duration,
          delay: delay,
          curve: Curves.easeOut,
        )
        .move(
          begin: begin,
          end: Offset.zero,
          duration: duration,
          delay: delay,
          curve: Curves.easeOut,
        );
    }
    
    return animatedWidget;
  }
}