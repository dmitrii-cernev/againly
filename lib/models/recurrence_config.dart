import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'recurrence_config.g.dart';

@HiveType(typeId: 3)
enum RecurrenceUnit {
  @HiveField(0)
  none,
  
  @HiveField(1)
  minutes,
  
  @HiveField(2)
  hours,
  
  @HiveField(3)
  days,
  
  @HiveField(4)
  weeks,
  
  @HiveField(5)
  months,
}

@HiveType(typeId: 4)
class RecurrenceConfig {
  @HiveField(0)
  final RecurrenceUnit unit;
  
  @HiveField(1)
  final int interval;
  
  @HiveField(2)
  final int? resetTimeHour;
  
  @HiveField(3)
  final int? resetTimeMinute;
  
  const RecurrenceConfig({
    this.unit = RecurrenceUnit.none,
    this.interval = 1,
    this.resetTimeHour,
    this.resetTimeMinute,
  });
  
  RecurrenceConfig copyWith({
    RecurrenceUnit? unit,
    int? interval,
    int? resetTimeHour,
    int? resetTimeMinute,
  }) {
    return RecurrenceConfig(
      unit: unit ?? this.unit,
      interval: interval ?? this.interval,
      resetTimeHour: resetTimeHour ?? this.resetTimeHour,
      resetTimeMinute: resetTimeMinute ?? this.resetTimeMinute,
    );
  }
  
  bool get isNone => unit == RecurrenceUnit.none;
  
  bool get hasFixedTime => resetTimeHour != null && resetTimeMinute != null;
  
  bool get isRelativeMode => !isNone && !hasFixedTime;
  
  bool get isFixedMode => !isNone && hasFixedTime;
  
  TimeOfDay? get resetTime {
    if (resetTimeHour == null || resetTimeMinute == null) return null;
    return TimeOfDay(hour: resetTimeHour!, minute: resetTimeMinute!);
  }
  
  Duration? get intervalDuration {
    if (isNone) return null;
    
    switch (unit) {
      case RecurrenceUnit.none:
        return null;
      case RecurrenceUnit.minutes:
        return Duration(minutes: interval);
      case RecurrenceUnit.hours:
        return Duration(hours: interval);
      case RecurrenceUnit.days:
        return Duration(days: interval);
      case RecurrenceUnit.weeks:
        return Duration(days: interval * 7);
      case RecurrenceUnit.months:
        return Duration(days: interval * 30);
    }
  }
  
  String get displayText {
    if (isNone) return 'No recurrence';
    
    String unitText;
    switch (unit) {
      case RecurrenceUnit.none:
        return 'No recurrence';
      case RecurrenceUnit.minutes:
        unitText = interval == 1 ? 'minute' : 'minutes';
        break;
      case RecurrenceUnit.hours:
        unitText = interval == 1 ? 'hour' : 'hours';
        break;
      case RecurrenceUnit.days:
        unitText = interval == 1 ? 'day' : 'days';
        break;
      case RecurrenceUnit.weeks:
        unitText = interval == 1 ? 'week' : 'weeks';
        break;
      case RecurrenceUnit.months:
        unitText = interval == 1 ? 'month' : 'months';
        break;
    }
    
    String baseText = 'Every ${interval == 1 ? '' : '$interval '}$unitText';
    
    if (hasFixedTime) {
      final time = resetTime!;
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      baseText += ' at $timeStr';
    }
    
    return baseText;
  }
  
  String get shortDisplayText {
    if (isNone) return 'None';
    
    String unitText;
    switch (unit) {
      case RecurrenceUnit.none:
        return 'None';
      case RecurrenceUnit.minutes:
        unitText = 'min';
        break;
      case RecurrenceUnit.hours:
        unitText = 'hr';
        break;
      case RecurrenceUnit.days:
        unitText = 'd';
        break;
      case RecurrenceUnit.weeks:
        unitText = 'w';
        break;
      case RecurrenceUnit.months:
        unitText = 'm';
        break;
    }
    
    final timeStr = hasFixedTime ? '${resetTime!.hour.toString().padLeft(2, '0')}:${resetTime!.minute.toString().padLeft(2, '0')}' : '';
    return '$interval$unitText${hasFixedTime ? ' @$timeStr' : ''}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceConfig &&
        other.unit == unit &&
        other.interval == interval &&
        other.resetTimeHour == resetTimeHour &&
        other.resetTimeMinute == resetTimeMinute;
  }
  
  @override
  int get hashCode {
    return Object.hash(unit, interval, resetTimeHour, resetTimeMinute);
  }
}

extension RecurrenceUnitExtension on RecurrenceUnit {
  String get displayName {
    switch (this) {
      case RecurrenceUnit.none:
        return 'None';
      case RecurrenceUnit.minutes:
        return 'Minutes';
      case RecurrenceUnit.hours:
        return 'Hours';
      case RecurrenceUnit.days:
        return 'Days';
      case RecurrenceUnit.weeks:
        return 'Weeks';
      case RecurrenceUnit.months:
        return 'Months';
    }
  }
  
  bool get allowsFixedTime {
    switch (this) {
      case RecurrenceUnit.none:
      case RecurrenceUnit.minutes:
      case RecurrenceUnit.hours:
        return false;
      case RecurrenceUnit.days:
      case RecurrenceUnit.weeks:
      case RecurrenceUnit.months:
        return true;
    }
  }
}