import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 1)
class ChecklistItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final bool isCompleted;
  
  ChecklistItem({
    String? id,
    required this.text,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
  
  ChecklistItem copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}