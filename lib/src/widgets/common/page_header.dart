// widgets/common/page_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool animate;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.animate = true,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget header = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (animate) {
      return header
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -20, end: 0, duration: 400.ms, curve: Curves.easeOut);
    }

    return header;
  }
}