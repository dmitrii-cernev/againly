import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_item.dart';
import '../providers/checklist_provider.dart';

class ChecklistItemTile extends ConsumerStatefulWidget {
  final ChecklistItem item;
  final String checklistId;
  
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.checklistId,
  });
  
  @override
  ConsumerState<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends ConsumerState<ChecklistItemTile> {
  late TextEditingController _controller;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: widget.item.isCompleted,
          onChanged: (value) {
            ref.read(checklistProvider.notifier).toggleChecklistItem(
              widget.checklistId,
              widget.item.id,
            );
          },
        ),
        title: _isEditing ? _buildEditingField() : _buildDisplayText(theme),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _startEditing();
                break;
              case 'delete':
                _deleteItem();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDisplayText(ThemeData theme) {
    return GestureDetector(
      onDoubleTap: _startEditing,
      child: Text(
        widget.item.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          decoration: widget.item.isCompleted ? TextDecoration.lineThrough : null,
          color: widget.item.isCompleted 
            ? theme.colorScheme.onSurfaceVariant 
            : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
  
  Widget _buildEditingField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (value) {
        _saveEdit();
      },
      onTapOutside: (event) {
        _saveEdit();
      },
    );
  }
  
  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }
  
  void _saveEdit() {
    if (_controller.text.trim().isEmpty) {
      _deleteItem();
      return;
    }
    
    if (_controller.text.trim() != widget.item.text) {
      final updatedItem = widget.item.copyWith(text: _controller.text.trim());
      ref.read(checklistProvider.notifier).updateChecklistItem(
        widget.checklistId,
        updatedItem,
      );
    }
    
    setState(() {
      _isEditing = false;
    });
  }
  
  void _deleteItem() {
    ref.read(checklistProvider.notifier).removeItemFromChecklist(
      widget.checklistId,
      widget.item.id,
    );
  }
}