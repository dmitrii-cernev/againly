import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../services/storage_service.dart';
import '../services/recurrence_service.dart';

class ChecklistNotifier extends StateNotifier<AsyncValue<List<Checklist>>> {
  ChecklistNotifier() : super(const AsyncValue.loading()) {
    _loadChecklists();
  }
  
  Future<void> _loadChecklists() async {
    try {
      await RecurrenceService.checkAndResetChecklists();
      final checklists = StorageService.getAllChecklists();
      state = AsyncValue.data(checklists);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> refreshChecklists() async {
    await _loadChecklists();
  }
  
  Future<void> createChecklist(Checklist checklist) async {
    try {
      await StorageService.saveChecklist(checklist);
      await _loadChecklists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateChecklist(Checklist checklist) async {
    try {
      await StorageService.updateChecklist(checklist);
      await _loadChecklists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteChecklist(String id) async {
    try {
      await StorageService.deleteChecklist(id);
      await _loadChecklists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> toggleChecklistItem(String checklistId, String itemId) async {
    final checklist = StorageService.getChecklistById(checklistId);
    if (checklist == null) return;
    
    final updatedItems = checklist.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    
    // Sort items: unchecked items first, then checked items
    updatedItems.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    
    final updatedChecklist = checklist.copyWith(items: updatedItems);
    await updateChecklist(updatedChecklist);
  }
  
  Future<void> addItemToChecklist(String checklistId, String itemText) async {
    final checklist = StorageService.getChecklistById(checklistId);
    if (checklist == null) return;
    
    final newItem = ChecklistItem(text: itemText);
    final updatedItems = [...checklist.items, newItem];
    final updatedChecklist = checklist.copyWith(items: updatedItems);
    
    await updateChecklist(updatedChecklist);
  }
  
  Future<void> removeItemFromChecklist(String checklistId, String itemId) async {
    final checklist = StorageService.getChecklistById(checklistId);
    if (checklist == null) return;
    
    final updatedItems = checklist.items.where((item) => item.id != itemId).toList();
    final updatedChecklist = checklist.copyWith(items: updatedItems);
    
    await updateChecklist(updatedChecklist);
  }
  
  Future<void> updateChecklistItem(String checklistId, ChecklistItem updatedItem) async {
    final checklist = StorageService.getChecklistById(checklistId);
    if (checklist == null) return;
    
    final updatedItems = checklist.items.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();
    
    final updatedChecklist = checklist.copyWith(items: updatedItems);
    await updateChecklist(updatedChecklist);
  }

  Future<void> deleteMultipleChecklists(List<String> checklistIds) async {
    try {
      for (final id in checklistIds) {
        await StorageService.deleteChecklist(id);
      }
      await _loadChecklists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetMultipleChecklists(List<String> checklistIds) async {
    try {
      for (final id in checklistIds) {
        final checklist = StorageService.getChecklistById(id);
        if (checklist != null) {
          final resetItems = checklist.items.map((item) => 
            item.copyWith(isCompleted: false)
          ).toList();
          final resetChecklist = checklist.copyWith(items: resetItems);
          await StorageService.updateChecklist(resetChecklist);
        }
      }
      await _loadChecklists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final checklistProvider = StateNotifierProvider<ChecklistNotifier, AsyncValue<List<Checklist>>>((ref) {
  return ChecklistNotifier();
});