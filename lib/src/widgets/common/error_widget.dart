// widgets/common/error_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gam3ya/src/widgets/common/custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 70,
              color: theme.colorScheme.error,
            )
                .animate()
                .shake(duration: 400.ms)
                .then(delay: 200.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),
            if (onRetry != null && buttonText != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText!,
                onPressed: onRetry!,
                icon: Icons.refresh,
                width: 180,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}