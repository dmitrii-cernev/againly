import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final bool isSelectionMode;
  final Set<String> selectedChecklistIds;

  const SelectionState({
    this.isSelectionMode = false,
    this.selectedChecklistIds = const {},
  });

  SelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedChecklistIds,
  }) {
    return SelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedChecklistIds: selectedChecklistIds ?? this.selectedChecklistIds,
    );
  }

  int get selectedCount => selectedChecklistIds.length;
  bool isSelected(String id) => selectedChecklistIds.contains(id);
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(const SelectionState());

  void enterSelectionMode([String? initialSelectedId]) {
    final selectedIds = initialSelectedId != null 
        ? {initialSelectedId} 
        : <String>{};
    
    state = state.copyWith(
      isSelectionMode: true,
      selectedChecklistIds: selectedIds,
    );
  }

  void exitSelectionMode() {
    state = const SelectionState();
  }

  void toggleSelection(String checklistId) {
    if (!state.isSelectionMode) {
      enterSelectionMode(checklistId);
      return;
    }

    final newSelectedIds = Set<String>.from(state.selectedChecklistIds);
    if (newSelectedIds.contains(checklistId)) {
      newSelectedIds.remove(checklistId);
    } else {
      newSelectedIds.add(checklistId);
    }

    if (newSelectedIds.isEmpty) {
      exitSelectionMode();
    } else {
      state = state.copyWith(selectedChecklistIds: newSelectedIds);
    }
  }

  void selectAll(List<String> allChecklistIds) {
    if (!state.isSelectionMode) return;
    
    state = state.copyWith(
      selectedChecklistIds: Set<String>.from(allChecklistIds),
    );
  }

  void clearSelection() {
    if (!state.isSelectionMode) return;
    
    exitSelectionMode();
  }
}

final selectionProvider = StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
  return SelectionNotifier();
});