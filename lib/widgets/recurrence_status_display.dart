import 'package:flutter/material.dart';
import '../models/recurrence_config.dart';

class RecurrenceStatusDisplay extends StatelessWidget {
  final RecurrenceConfig config;
  final VoidCallback onTap;

  const RecurrenceStatusDisplay({
    super.key,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.refresh,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recurrence:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                config.displayText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: config.isNone 
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                  fontWeight: config.isNone ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}