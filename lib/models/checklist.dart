import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'checklist_item.dart';
import 'recurrence_type.dart';

part 'checklist.g.dart';

@HiveType(typeId: 0)
class Checklist {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final List<ChecklistItem> items;
  
  @HiveField(3)
  final RecurrenceType recurrence;
  
  @HiveField(4)
  final DateTime? lastReset;
  
  @HiveField(5)
  final DateTime createdAt;
  
  Checklist({
    String? id,
    this.title = '',
    List<ChecklistItem>? items,
    this.recurrence = RecurrenceType.none,
    this.lastReset,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       items = items ?? [],
       createdAt = createdAt ?? DateTime.now();
  
  Checklist copyWith({
    String? title,
    List<ChecklistItem>? items,
    RecurrenceType? recurrence,
    DateTime? lastReset,
  }) {
    return Checklist(
      id: id,
      title: title ?? this.title,
      items: items ?? this.items,
      recurrence: recurrence ?? this.recurrence,
      lastReset: lastReset ?? this.lastReset,
      createdAt: createdAt,
    );
  }
  
  int get completedItemsCount => items.where((item) => item.isCompleted).length;
  
  int get totalItemsCount => items.length;
  
  double get completionPercentage {
    if (totalItemsCount == 0) return 0.0;
    return completedItemsCount / totalItemsCount;
  }
  
  bool get isCompleted => totalItemsCount > 0 && completedItemsCount == totalItemsCount;
  
  bool get hasTitle => title.trim().isNotEmpty;
  
  String get displayTitle {
    if (hasTitle) return title;
    
    if (items.isEmpty) {
      return 'Empty checklist';
    } else if (items.length == 1) {
      return items.first.text;
    } else {
      return '${items.first.text} +${items.length - 1} more';
    }
  }
  
  bool get needsReset {
    if (recurrence == RecurrenceType.none || lastReset == null) return false;
    
    final duration = recurrence.duration;
    if (duration == null) return false;
    
    return DateTime.now().isAfter(lastReset!.add(duration));
  }
  
  Checklist resetItems() {
    final resetItems = items.map((item) => item.copyWith(isCompleted: false)).toList();
    return copyWith(
      items: resetItems,
      lastReset: DateTime.now(),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Checklist && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}