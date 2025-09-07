import 'package:hive_flutter/hive_flutter.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/recurrence_config.dart';

class StorageService {
  static const String _checklistBoxName = 'checklists';
  
  static late Box<Checklist> _checklistBox;
  
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(ChecklistAdapter());
    Hive.registerAdapter(ChecklistItemAdapter());
    Hive.registerAdapter(RecurrenceConfigAdapter());
    Hive.registerAdapter(RecurrenceUnitAdapter());
    
    _checklistBox = await Hive.openBox<Checklist>(_checklistBoxName);
  }
  
  static List<Checklist> getAllChecklists() {
    return _checklistBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  static Future<void> saveChecklist(Checklist checklist) async {
    await _checklistBox.put(checklist.id, checklist);
  }
  
  static Future<void> deleteChecklist(String id) async {
    await _checklistBox.delete(id);
  }
  
  static Checklist? getChecklistById(String id) {
    return _checklistBox.get(id);
  }
  
  static Future<void> updateChecklist(Checklist checklist) async {
    await _checklistBox.put(checklist.id, checklist);
  }
  
  static Stream<BoxEvent> watchChecklists() {
    return _checklistBox.watch();
  }
  
  static Future<void> clearAll() async {
    await _checklistBox.clear();
  }
}