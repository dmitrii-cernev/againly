import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/recurrence_type.dart';
import '../providers/checklist_provider.dart';

class CreateChecklistScreen extends ConsumerStatefulWidget {
  const CreateChecklistScreen({super.key});

  @override
  ConsumerState<CreateChecklistScreen> createState() =>
      _CreateChecklistScreenState();
}

class _CreateChecklistScreenState extends ConsumerState<CreateChecklistScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();
  final List<String> _items = [];
  RecurrenceType _selectedRecurrence = RecurrenceType.none;

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _itemFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _canCreate()) {
          _createChecklist();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Checklist'),
        ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Icon(Icons.refresh, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recurrence:',
                  style: theme.textTheme.labelLarge?.copyWith(
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
                _getRecurrenceDescription(_selectedRecurrence),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 24),

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

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    focusNode: _itemFocusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Add an item...',
                      border: InputBorder.none,
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

            const SizedBox(height: 16),

            Expanded(
              child: _items.isEmpty
                  ? _buildEmptyItemsState(context)
                  : ReorderableListView.builder(
                      itemCount: _items.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _items.removeAt(oldIndex);
                          _items.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        return Card(
                          key: ValueKey(_items[index]),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            title: Text(_items[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyItemsState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No items added',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items or a title to create your checklist',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add(text);
        _itemController.clear();
      });
      // Keep focus on the input field after adding item
      _itemFocusNode.requestFocus();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  bool _canCreate() {
    // Allow creating checklists without titles, but require at least one item if no title
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasItems = _items.isNotEmpty;
    return hasTitle || hasItems;
  }

  String _getRecurrenceDescription(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return '';
      case RecurrenceType.daily:
        return 'This checklist will reset every day';
      case RecurrenceType.weekly:
        return 'This checklist will reset every week';
      case RecurrenceType.monthly:
        return 'This checklist will reset every month (30 days)';
    }
  }

  void _createChecklist() {
    if (!_canCreate()) return;

    final checklistItems = _items
        .map((text) => ChecklistItem(text: text))
        .toList();

    final checklist = Checklist(
      title: _titleController.text.trim(), // Can be empty now
      items: checklistItems,
      recurrence: _selectedRecurrence,
      lastReset: _selectedRecurrence != RecurrenceType.none
          ? DateTime.now()
          : null,
    );

    ref.read(checklistProvider.notifier).createChecklist(checklist);
  }
}

