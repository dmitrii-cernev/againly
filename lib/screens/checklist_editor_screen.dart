import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/recurrence_config.dart';
import '../providers/checklist_provider.dart';
import '../widgets/checklist_item_tile.dart';
import '../widgets/recurrence_status_display.dart';
import '../widgets/recurrence_bottom_sheet.dart';

class ChecklistEditorScreen extends ConsumerStatefulWidget {
  final Checklist? checklist;
  
  const ChecklistEditorScreen({
    super.key,
    this.checklist,
  });
  
  bool get isCreateMode => checklist == null;
  
  @override
  ConsumerState<ChecklistEditorScreen> createState() => _ChecklistEditorScreenState();
}

class _ChecklistEditorScreenState extends ConsumerState<ChecklistEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _itemController;
  final FocusNode _itemFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  
  // For create mode: local state
  final List<String> _localItems = [];
  RecurrenceConfig _selectedRecurrence = const RecurrenceConfig();
  
  bool get isCreateMode => widget.isCreateMode;
  
  // Helper method to get the current checklist from the provider (edit mode only)
  Checklist? _getCurrentChecklist() {
    if (isCreateMode) return null;
    
    return ref.read(checklistProvider).when(
      data: (checklists) => checklists.firstWhere(
        (c) => c.id == widget.checklist!.id,
        orElse: () => widget.checklist!,
      ),
      loading: () => widget.checklist,
      error: (_, __) => widget.checklist,
    );
  }
  
  @override
  void initState() {
    super.initState();
    
    if (isCreateMode) {
      // Create mode: start with empty state
      _titleController = TextEditingController();
      _itemController = TextEditingController();
    } else {
      // Edit mode: initialize with existing checklist data
      _titleController = TextEditingController(text: widget.checklist!.title);
      _itemController = TextEditingController();
      _selectedRecurrence = widget.checklist!.recurrence;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _itemFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the provider to get the current state of checklists (edit mode only)
    final currentChecklist = isCreateMode ? null : _getCurrentChecklist();
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && isCreateMode && _canCreate()) {
          _createChecklist();
        }
      },
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isCreateMode ? 'New Checklist' : 'Checklist'),
            actions: isCreateMode ? null : [
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
          
          body: Hero(
            tag: isCreateMode ? 'create_checklist' : 'checklist_${widget.checklist!.id}',
            child: Material(
              child: Column(
                children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title field
                            TextField(
                              controller: _titleController,
                              style: theme.textTheme.headlineSmall,
                              decoration: const InputDecoration(
                                hintText: 'Title',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                if (isCreateMode) {
                                  setState(() {});
                                } else {
                                  _updateTitle(value);
                                }
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Reset button (edit mode only)
                            if (!isCreateMode) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _showResetDialog(),
                                    icon: const Icon(Icons.restart_alt, size: 16),
                                    label: const Text('Reset'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Recurrence status display
                            RecurrenceStatusDisplay(
                              config: _selectedRecurrence,
                              onTap: () => _showRecurrenceBottomSheet(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Progress indicator (edit mode only)
                            if (!isCreateMode && currentChecklist != null && currentChecklist.items.isNotEmpty)
                              Text(
                                'Progress: ${currentChecklist.completedItemsCount}/${currentChecklist.totalItemsCount} completed',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            
                            if (!isCreateMode) const SizedBox(height: 16),
                            
                            // Items section header (create mode only)
                            if (isCreateMode) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.checklist, size: 16, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Items (optional):',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                      
                      // Items list
                      _buildItemsList(context, currentChecklist),
                    ],
                  ),
                ),
              ),
              
              // Add item field at bottom
              _buildAddItemField(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildItemsList(BuildContext context, Checklist? currentChecklist) {
    final items = isCreateMode ? _localItems : (currentChecklist?.items ?? []);
    final isEmpty = items.isEmpty;
    
    if (isEmpty) {
      return _buildEmptyItemsState(context);
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        onReorder: (oldIndex, newIndex) {
          if (isCreateMode) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _localItems.removeAt(oldIndex);
              _localItems.insert(newIndex, item);
            });
          } else {
            ref.read(checklistProvider.notifier).reorderChecklistItems(
              widget.checklist!.id,
              oldIndex,
              newIndex,
            );
          }
        },
        itemBuilder: (context, index) {
          if (isCreateMode) {
            // Create mode: show simple cards with text
            return Card(
              key: ValueKey('item_$index'),
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(_localItems[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeLocalItem(index),
                ),
              ),
            );
          } else {
            // Edit mode: show checklist item tiles with checkboxes
            final item = currentChecklist!.items[index];
            return ChecklistItemTile(
              key: ValueKey(item.id),
              item: item,
              checklistId: widget.checklist!.id,
              showDragHandle: true,
            );
          }
        },
      ),
    );
  }
  
  Widget _buildEmptyItemsState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      alignment: Alignment.center,
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
              isCreateMode ? 'No items added' : 'No items yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCreateMode 
                ? 'Add items or a title to create your checklist'
                : 'Add your first item below',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
              controller: _itemController,
              focusNode: _itemFocusNode,
              autofocus: isCreateMode,
              decoration: InputDecoration(
                hintText: isCreateMode ? 'Add an item...' : 'Add new item...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (value) => _addItem(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  
  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isNotEmpty) {
      if (isCreateMode) {
        setState(() {
          _localItems.add(text);
          _itemController.clear();
        });
      } else {
        ref.read(checklistProvider.notifier).addItemToChecklist(
          widget.checklist!.id,
          text,
        );
        _itemController.clear();
      }
      // Keep focus on the input field after adding item
      _itemFocusNode.requestFocus();
    }
  }
  
  void _removeLocalItem(int index) {
    setState(() {
      _localItems.removeAt(index);
    });
  }
  
  bool _canCreate() {
    // Allow creating checklists without titles, but require at least one item if no title
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasItems = _localItems.isNotEmpty;
    return hasTitle || hasItems;
  }
  
  void _createChecklist() {
    if (!_canCreate()) return;
    
    final checklistItems = _localItems
        .map((text) => ChecklistItem(text: text))
        .toList();
    
    final checklist = Checklist(
      title: _titleController.text.trim(), // Can be empty now
      items: checklistItems,
      recurrence: _selectedRecurrence,
      lastReset: !_selectedRecurrence.isNone
          ? DateTime.now()
          : null,
    );
    
    ref.read(checklistProvider.notifier).createChecklist(checklist);
  }
  
  void _updateTitle(String title) {
    final currentChecklist = _getCurrentChecklist();
    if (currentChecklist == null) return;
    
    final trimmedTitle = title.trim();
    
    // Update if the trimmed title is different from current title
    if (trimmedTitle != currentChecklist.title) {
      final updatedChecklist = currentChecklist.copyWith(title: trimmedTitle);
      ref.read(checklistProvider.notifier).updateChecklist(updatedChecklist);
    }
  }
  
  void _updateRecurrence(RecurrenceConfig recurrence) {
    final currentChecklist = _getCurrentChecklist();
    if (currentChecklist == null) return;
    
    final updatedChecklist = currentChecklist.copyWith(
      recurrence: recurrence,
      lastReset: recurrence.isNone ? null : DateTime.now(),
    );
    ref.read(checklistProvider.notifier).updateChecklist(updatedChecklist);
  }

  void _showRecurrenceBottomSheet() async {
    final result = await RecurrenceBottomSheet.show(
      context: context,
      initialConfig: _selectedRecurrence,
    );
    
    if (result != null) {
      setState(() {
        _selectedRecurrence = result;
      });
      if (!isCreateMode) {
        _updateRecurrence(result);
      }
    }
  }
  
  void _resetChecklist() {
    final currentChecklist = _getCurrentChecklist();
    if (currentChecklist == null) return;
    
    final resetChecklist = currentChecklist.resetItems();
    ref.read(checklistProvider.notifier).updateChecklist(resetChecklist);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All items reset'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _showResetDialog() {
    final currentChecklist = _getCurrentChecklist();
    if (currentChecklist == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Checklist'),
        content: Text('Are you sure you want to reset all items in "${currentChecklist.displayTitle}"? This will uncheck all completed items.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _resetChecklist();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog() {
    final currentChecklist = _getCurrentChecklist();
    if (currentChecklist == null) return;
    
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
              ref.read(checklistProvider.notifier).deleteChecklist(widget.checklist!.id);
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