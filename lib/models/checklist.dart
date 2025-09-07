import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'checklist_item.dart';
import 'recurrence_config.dart';

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
  final RecurrenceConfig recurrence;
  
  @HiveField(4)
  final DateTime? lastReset;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime? lastInteractionAt;
  
  Checklist({
    String? id,
    this.title = '',
    List<ChecklistItem>? items,
    this.recurrence = const RecurrenceConfig(),
    this.lastReset,
    DateTime? createdAt,
    this.lastInteractionAt,
  }) : id = id ?? const Uuid().v4(),
       items = items ?? [],
       createdAt = createdAt ?? DateTime.now();
  
  Checklist copyWith({
    String? title,
    List<ChecklistItem>? items,
    RecurrenceConfig? recurrence,
    DateTime? lastReset,
    DateTime? lastInteractionAt,
  }) {
    return Checklist(
      id: id,
      title: title ?? this.title,
      items: items ?? this.items,
      recurrence: recurrence ?? this.recurrence,
      lastReset: lastReset ?? this.lastReset,
      createdAt: createdAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
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
    if (recurrence.isNone) return false;
    
    final duration = recurrence.intervalDuration;
    if (duration == null) return false;
    
    final now = DateTime.now();
    
    if (recurrence.isFixedMode) {
      final resetTime = recurrence.resetTime;
      if (resetTime == null) return false;
      
      final lastResetDate = lastReset ?? createdAt;
      final nextResetDate = _getNextFixedResetDateTime(lastResetDate, resetTime, duration);
      
      return now.isAfter(nextResetDate);
    } else {
      final referenceTime = lastInteractionAt ?? lastReset ?? createdAt;
      return now.isAfter(referenceTime.add(duration));
    }
  }
  
  DateTime _getNextFixedResetDateTime(DateTime lastReset, TimeOfDay resetTime, Duration interval) {
    DateTime candidateReset = DateTime(
      lastReset.year,
      lastReset.month,
      lastReset.day,
      resetTime.hour,
      resetTime.minute,
    );
    
    while (candidateReset.isBefore(lastReset)) {
      candidateReset = candidateReset.add(interval);
    }
    
    return candidateReset;
  }
  
  Checklist resetItems() {
    final resetItems = items.map((item) => item.copyWith(isCompleted: false)).toList();
    return copyWith(
      items: resetItems,
      lastReset: DateTime.now(),
    );
  }
  
  Checklist recordInteraction() {
    if (recurrence.isRelativeMode) {
      return copyWith(lastInteractionAt: DateTime.now());
    }
    return this;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Checklist && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}