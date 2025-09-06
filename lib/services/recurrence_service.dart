import '../models/checklist.dart';
import '../models/recurrence_type.dart';
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
    if (checklist.recurrence.duration == null) return null;
    
    final lastReset = checklist.lastReset ?? checklist.createdAt;
    return lastReset.add(checklist.recurrence.duration!);
  }
  
  static String getNextResetText(Checklist checklist) {
    final nextReset = getNextResetDate(checklist);
    if (nextReset == null) return 'No recurrence';
    
    final now = DateTime.now();
    final difference = nextReset.difference(now);
    
    if (difference.inDays > 0) {
      return 'Resets in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'Resets in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'Resets in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Ready to reset';
    }
  }
}