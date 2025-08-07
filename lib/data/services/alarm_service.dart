import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/data/repositories/local_todo_repository.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService(ref);
});

class AlarmService {
  final Ref ref;
  
  AlarmService(this.ref);

  Future<Todo?> checkPendingAlarm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingTaskId = prefs.getString('pending_alarm_task');
      
      if (pendingTaskId != null) {
        // Remove o alarme pendente para evitar loops
        await prefs.remove('pending_alarm_task');
        
        // Busca a tarefa
        final repository = ref.read(localTodoRepositoryProvider);
        final todos = await repository.getTodos();
        
        final task = todos.where((todo) => todo.id == pendingTaskId).firstOrNull;
        
        if (task != null && !task.isCompleted) {
          return task;
        }
      }
      
      return null;
    } catch (e) {
      log('Error checking pending alarm: $e');
      return null;
    }
  }

  Future<void> clearPendingAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_alarm_task');
  }
}
