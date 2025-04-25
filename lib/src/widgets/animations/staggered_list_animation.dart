// widgets/animations/staggered_list_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDuration;
  final Duration itemDuration;
  final Axis direction;
  final bool fadeIn;
  final double slideOffset;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.direction = Axis.vertical,
    this.fadeIn = true,
    this.slideOffset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final animatedChildren = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      final delay = staggerDuration * i;
      
      Widget animatedChild = children[i];
      
      if (fadeIn && direction == Axis.vertical) {
        animatedChild = animatedChild
            .animate()
            .fadeIn(duration: itemDuration, delay: delay)
            .moveY(begin: slideOffset, end: 0, duration: itemDuration, delay: delay, curve: Curves.easeOutCubic);
      } else if (fadeIn && direction == Axis.horizontal) {
        animatedChild = animatedChild
            .animate()
            .fadeIn(duration: itemDuration, delay: delay)
            .moveX(begin: slideOffset, end: 0, duration: itemDuration, delay: delay, curve: Curves.easeOutCubic);
      } else if (direction == Axis.vertical) {
        animatedChild = animatedChild
            .animate()
            .moveY(begin: slideOffset, end: 0, duration: itemDuration, delay: delay, curve: Curves.easeOutCubic);
      } else {
        animatedChild = animatedChild
            .animate()
            .moveX(begin: slideOffset, end: 0, duration: itemDuration, delay: delay, curve: Curves.easeOutCubic);
      }
      
      animatedChildren.add(animatedChild);
    }
    
    return direction == Axis.vertical
        ? Column(children: animatedChildren)
        : Row(children: animatedChildren);
  }
}