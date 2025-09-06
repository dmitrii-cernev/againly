import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/recurrence_type.dart';
import '../providers/checklist_provider.dart';
import '../services/recurrence_service.dart';

class ChecklistCard extends ConsumerWidget {
  final Checklist checklist;
  final VoidCallback onTap;
  
  const ChecklistCard({
    super.key,
    required this.checklist,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      checklist.displayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontStyle: checklist.hasTitle ? FontStyle.normal : FontStyle.italic,
                        color: checklist.hasTitle 
                          ? theme.textTheme.titleMedium?.color
                          : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (checklist.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: checklist.isCompleted 
                          ? colorScheme.primary 
                          : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${checklist.completedItemsCount}/${checklist.totalItemsCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: checklist.isCompleted 
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (checklist.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...checklist.items.take(3).map((item) => 
                  _buildItemTile(context, ref, item)
                ),
                if (checklist.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${checklist.items.length - 3} more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
              
              if (checklist.recurrence.displayName != 'None') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${checklist.recurrence.displayName} • ${RecurrenceService.getNextResetText(checklist)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildItemTile(BuildContext context, WidgetRef ref, ChecklistItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: item.isCompleted,
              onChanged: (value) {
                ref.read(checklistProvider.notifier).toggleChecklistItem(
                  checklist.id,
                  item.id,
                );
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                color: item.isCompleted 
                  ? colorScheme.onSurfaceVariant 
                  : colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}