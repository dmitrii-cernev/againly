import 'package:hive/hive.dart';

part 'recurrence_type.g.dart';

@HiveType(typeId: 2)
enum RecurrenceType {
  @HiveField(0)
  none,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }
  
  Duration? get duration {
    switch (this) {
      case RecurrenceType.none:
        return null;
      case RecurrenceType.daily:
        return const Duration(days: 1);
      case RecurrenceType.weekly:
        return const Duration(days: 7);
      case RecurrenceType.monthly:
        return const Duration(days: 30);
    }
  }
}