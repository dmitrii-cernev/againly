import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/recurrence_type.dart';
import '../providers/checklist_provider.dart';

class CreateChecklistScreen extends ConsumerStatefulWidget {
  const CreateChecklistScreen({super.key});
  
  @override
  ConsumerState<CreateChecklistScreen> createState() => _CreateChecklistScreenState();
}

class _CreateChecklistScreenState extends ConsumerState<CreateChecklistScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final List<String> _items = [];
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  
  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Checklist'),
        actions: [
          TextButton(
            onPressed: _canCreate() ? _createChecklist : null,
            child: const Text('Create'),
          ),
        ],
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
                hintText: 'Checklist title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: 24),
            
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
                Icon(
                  Icons.checklist,
                  size: 16,
                  color: colorScheme.primary,
                ),
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
                    decoration: const InputDecoration(
                      hintText: 'Add an item...',
                      border: OutlineInputBorder(),
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
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: const Icon(Icons.drag_handle),
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
    );
  }
  
  Widget _buildEmptyItemsState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
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
            'No items added',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can create an empty checklist and add items later',
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
    }
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
  
  bool _canCreate() {
    return _titleController.text.trim().isNotEmpty;
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
      title: _titleController.text.trim(),
      items: checklistItems,
      recurrence: _selectedRecurrence,
      lastReset: _selectedRecurrence != RecurrenceType.none ? DateTime.now() : null,
    );
    
    ref.read(checklistProvider.notifier).createChecklist(checklist);
    Navigator.of(context).pop();
  }
}