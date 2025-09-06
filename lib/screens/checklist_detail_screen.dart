import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/recurrence_type.dart';
import '../providers/checklist_provider.dart';
import '../widgets/checklist_item_tile.dart';
import '../services/recurrence_service.dart';

class ChecklistDetailScreen extends ConsumerStatefulWidget {
  final Checklist checklist;
  
  const ChecklistDetailScreen({
    super.key,
    required this.checklist,
  });
  
  @override
  ConsumerState<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends ConsumerState<ChecklistDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _newItemController;
  final FocusNode _newItemFocusNode = FocusNode();
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  
  // Helper method to get the current checklist from the provider
  Checklist _getCurrentChecklist() {
    return ref.read(checklistProvider).when(
      data: (checklists) => checklists.firstWhere(
        (c) => c.id == widget.checklist.id,
        orElse: () => widget.checklist,
      ),
      loading: () => widget.checklist,
      error: (_, __) => widget.checklist,
    );
  }
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.checklist.title);
    _newItemController = TextEditingController();
    _selectedRecurrence = widget.checklist.recurrence;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _newItemController.dispose();
    _newItemFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the provider to get the current state of checklists
    final checklistState = ref.watch(checklistProvider);
    
    // Find the current checklist from the provider state
    final currentChecklist = checklistState.when(
      data: (checklists) => checklists.firstWhere(
        (c) => c.id == widget.checklist.id,
        orElse: () => widget.checklist, // Fallback to original if not found
      ),
      loading: () => widget.checklist,
      error: (_, __) => widget.checklist,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
                case 'reset':
                  _resetChecklist();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reset All Items'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete Checklist'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: theme.textTheme.headlineSmall,
                  decoration: InputDecoration(
                    hintText: currentChecklist.hasTitle ? 'Checklist title' : 'Title (optional) • ${currentChecklist.displayTitle}',
                    border: InputBorder.none,
                    hintStyle: currentChecklist.hasTitle 
                      ? null 
                      : TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                  ),
                  onChanged: (value) => _updateTitle(value),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recurrence:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<RecurrenceType>(
                        value: _selectedRecurrence,
                        onChanged: (RecurrenceType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRecurrence = newValue;
                            });
                            _updateRecurrence(newValue);
                          }
                        },
                        items: RecurrenceType.values.map((RecurrenceType type) {
                          return DropdownMenuItem<RecurrenceType>(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                
                if (_selectedRecurrence != RecurrenceType.none) ...[
                  const SizedBox(height: 8),
                  Text(
                    RecurrenceService.getNextResetText(currentChecklist),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                if (currentChecklist.items.isNotEmpty)
                  Text(
                    'Progress: ${currentChecklist.completedItemsCount}/${currentChecklist.totalItemsCount} completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: currentChecklist.items.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentChecklist.items.length,
                    itemBuilder: (context, index) {
                      final item = currentChecklist.items[index];
                      return ChecklistItemTile(
                        item: item,
                        checklistId: widget.checklist.id,
                      );
                    },
                  ),
          ),
          
          _buildAddItemField(context),
        ],
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
            Icon(
              Icons.playlist_add,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No items yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first item below',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddItemField(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newItemController,
              focusNode: _newItemFocusNode,
              decoration: const InputDecoration(
                hintText: 'Add new item...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (value) => _addNewItem(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _addNewItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  
  void _addNewItem() {
    final text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      ref.read(checklistProvider.notifier).addItemToChecklist(
        widget.checklist.id,
        text,
      );
      _newItemController.clear();
      // Keep focus on the input field after adding item
      _newItemFocusNode.requestFocus();
    }
  }
  
  void _updateTitle(String title) {
    final currentChecklist = _getCurrentChecklist();
    final trimmedTitle = title.trim();
    
    // Update if the trimmed title is different from current title
    if (trimmedTitle != currentChecklist.title) {
      final updatedChecklist = currentChecklist.copyWith(title: trimmedTitle);
      ref.read(checklistProvider.notifier).updateChecklist(updatedChecklist);
    }
  }
  
  void _updateRecurrence(RecurrenceType recurrence) {
    final currentChecklist = _getCurrentChecklist();
    final updatedChecklist = currentChecklist.copyWith(
      recurrence: recurrence,
      lastReset: recurrence == RecurrenceType.none ? null : DateTime.now(),
    );
    ref.read(checklistProvider.notifier).updateChecklist(updatedChecklist);
  }
  
  void _resetChecklist() {
    final currentChecklist = _getCurrentChecklist();
    final resetChecklist = currentChecklist.resetItems();
    ref.read(checklistProvider.notifier).updateChecklist(resetChecklist);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All items reset'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _showDeleteDialog() {
    final currentChecklist = _getCurrentChecklist();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklist'),
        content: Text('Are you sure you want to delete "${currentChecklist.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(checklistProvider.notifier).deleteChecklist(widget.checklist.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close detail screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}