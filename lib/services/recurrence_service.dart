import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../models/recurrence_config.dart';
import 'storage_service.dart';

class RecurrenceService {
  static Future<void> checkAndResetChecklists() async {
    final checklists = StorageService.getAllChecklists();
    
    for (final checklist in checklists) {
      if (checklist.needsReset) {
        final resetChecklist = checklist.resetItems();
        await StorageService.updateChecklist(resetChecklist);
      }
    }
  }
  
  static DateTime? getNextResetDate(Checklist checklist) {
    if (checklist.recurrence.isNone) return null;
    
    final duration = checklist.recurrence.intervalDuration;
    if (duration == null) return null;
    
    final now = DateTime.now();
    
    if (checklist.recurrence.isFixedMode) {
      final resetTime = checklist.recurrence.resetTime;
      if (resetTime == null) return null;
      
      final lastResetDate = checklist.lastReset ?? checklist.createdAt;
      return _getNextFixedResetDateTime(lastResetDate, resetTime, duration, now);
    } else {
      final referenceTime = checklist.lastInteractionAt ?? checklist.lastReset ?? checklist.createdAt;
      return referenceTime.add(duration);
    }
  }
  
  static DateTime _getNextFixedResetDateTime(DateTime lastReset, TimeOfDay resetTime, Duration interval, DateTime now) {
    DateTime candidateReset = DateTime(
      lastReset.year,
      lastReset.month,
      lastReset.day,
      resetTime.hour,
      resetTime.minute,
    );
    
    while (candidateReset.isBefore(lastReset) || candidateReset.isBefore(now)) {
      candidateReset = candidateReset.add(interval);
    }
    
    return candidateReset;
  }
  
  static String getNextResetText(Checklist checklist) {
    if (checklist.recurrence.isNone) return 'No recurrence';
    
    final nextReset = getNextResetDate(checklist);
    if (nextReset == null) return 'No recurrence';
    
    final now = DateTime.now();
    final difference = nextReset.difference(now);
    
    String prefix = checklist.recurrence.isFixedMode ? 'Resets' : 'Resets after inactivity';
    
    if (difference.isNegative) {
      return 'Ready to reset';
    } else if (difference.inDays > 0) {
      return '$prefix in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '$prefix in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '$prefix in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Ready to reset';
    }
  }
  
  static String getRecurrenceDescription(RecurrenceConfig recurrence) {
    if (recurrence.isNone) return 'No automatic reset';
    
    String baseText = recurrence.displayText;
    
    if (recurrence.isFixedMode) {
      return '$baseText (Fixed schedule)';
    } else {
      return '$baseText (Resets after inactivity)';
    }
  }
}