import 'package:flutter/material.dart';
import 'ramez_button.dart';

class RamezErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const RamezErrorState({
    super.key,
    this.title = 'Connection Error',
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              ),
              child: Icon(Icons.error_outline, size: 54, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            RamezButton(
              label: retryLabel,
              onPressed: onRetry,
              icon: Icons.refresh,
              width: 160,
              variant: RamezButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
