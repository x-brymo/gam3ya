// widgets/common/custom_card.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: backgroundColor ?? theme.cardTheme.color,
      elevation: elevation ?? theme.cardTheme.elevation ?? 2,
      shadowColor: shadowColor ?? theme.shadowColor,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}