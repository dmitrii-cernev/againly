import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../providers/checklist_provider.dart';
import '../providers/selection_provider.dart';
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
    final selectionState = ref.watch(selectionProvider);
    final isSelected = selectionState.isSelected(checklist.id);
    
    return Card(
      elevation: isSelected ? 4 : null,
      color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: Stack(
        children: [
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              ref.read(selectionProvider.notifier).toggleSelection(checklist.id);
            },
            onSecondaryTap: () {
              ref.read(selectionProvider.notifier).toggleSelection(checklist.id);
            },
            child: InkWell(
              onTap: () {
                if (selectionState.isSelectionMode) {
                  ref.read(selectionProvider.notifier).toggleSelection(checklist.id);
                } else {
                  onTap();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: isSelected ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ) : null,
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
              
              if (!checklist.recurrence.isNone) ...[
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
                        '${checklist.recurrence.displayText} • ${RecurrenceService.getNextResetText(checklist)}',
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
            ),
          ),
          if (selectionState.isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      ref.read(selectionProvider.notifier).toggleSelection(checklist.id);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
        ],
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