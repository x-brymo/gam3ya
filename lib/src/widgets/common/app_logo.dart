// widgets/common/app_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Center(
            child: Text(
              'جمعيتي',
              style: TextStyle(
                color: primaryColor,
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    if (animate) {
      return logo
          .animate()
          .fadeIn(duration: 700.ms)
          .scaleXY(begin: 0.5, end: 1, duration: 700.ms, curve: Curves.elasticOut);
    }

    return logo;
  }
}