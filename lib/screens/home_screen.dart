import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/checklist.dart';
import '../providers/checklist_provider.dart';
import '../providers/selection_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/checklist_card.dart';
import 'create_checklist_screen.dart';
import 'checklist_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistState = ref.watch(checklistProvider);
    final selectionState = ref.watch(selectionProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: selectionState.isSelectionMode ? Container() : null,
        leadingWidth: selectionState.isSelectionMode ? 120 : null,
        title: selectionState.isSelectionMode 
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 300;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSelectionActions(context, ref, isCompact: isNarrow),
                      SizedBox(width: isNarrow ? 8 : 16),
                      Flexible(
                        child: Text(
                          '${selectionState.selectedCount} selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }
              )
            : null,
        actions: selectionState.isSelectionMode 
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref.read(selectionProvider.notifier).exitSelectionMode(),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(themeNotifier.currentThemeIcon),
                  tooltip: themeNotifier.currentThemeTooltip,
                  onPressed: () => themeNotifier.toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(checklistProvider.notifier).refreshChecklists(),
                ),
              ],
      ),
      body: checklistState.when(
        data: (checklists) => _buildChecklistGrid(context, ref, checklists),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(checklistProvider.notifier).refreshChecklists(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateChecklist(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChecklistGrid(
    BuildContext context,
    WidgetRef ref,
    List<Checklist> checklists,
  ) {
    if (checklists.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(checklistProvider.notifier).refreshChecklists(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MasonryGridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: checklists.length,
          itemBuilder: (context, index) {
            final checklist = checklists[index];
            return ChecklistCard(
              checklist: checklist,
              onTap: () => _navigateToChecklistDetail(context, checklist),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'No checklists yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first recurring checklist to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateChecklist(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Checklist'),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 500) return 2;
    return 1;
  }

  void _navigateToCreateChecklist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateChecklistScreen()),
    );
  }

  void _navigateToChecklistDetail(BuildContext context, Checklist checklist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChecklistDetailScreen(checklist: checklist),
      ),
    );
  }

  Widget _buildSelectionActions(BuildContext context, WidgetRef ref, {bool isCompact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete selected',
          onPressed: () => _showDeleteConfirmationDialog(context, ref),
          iconSize: isCompact ? 20 : 24,
          constraints: BoxConstraints(
            minWidth: isCompact ? 36 : 48,
            minHeight: isCompact ? 36 : 48,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset selected',
          onPressed: () => _showResetConfirmationDialog(context, ref),
          iconSize: isCompact ? 20 : 24,
          constraints: BoxConstraints(
            minWidth: isCompact ? 36 : 48,
            minHeight: isCompact ? 36 : 48,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionProvider);
    final selectedCount = selectionState.selectedCount;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklists'),
        content: Text('Are you sure you want to delete $selectedCount checklist${selectedCount > 1 ? 's' : ''}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(checklistProvider.notifier).deleteMultipleChecklists(
        selectionState.selectedChecklistIds.toList()
      );
      ref.read(selectionProvider.notifier).exitSelectionMode();
    }
  }

  Future<void> _showResetConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionProvider);
    final selectedCount = selectionState.selectedCount;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Checklists'),
        content: Text('Are you sure you want to reset $selectedCount checklist${selectedCount > 1 ? 's' : ''}? All items will be marked as incomplete.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(checklistProvider.notifier).resetMultipleChecklists(
        selectionState.selectedChecklistIds.toList()
      );
      ref.read(selectionProvider.notifier).exitSelectionMode();
    }
  }
}

