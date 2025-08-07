import 'dart:convert';
import 'dart:developer';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/data/services/notification_service.dart';

class BackgroundService {
  static const String _taskCheckerKey = 'taskChecker';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static void startTaskChecker() {
    Workmanager().registerPeriodicTask(
      _taskCheckerKey,
      _taskCheckerKey,
      frequency: const Duration(minutes: 1), // Verifica a cada 1 minuto
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static void stopTaskChecker() {
    Workmanager().cancelByUniqueName(_taskCheckerKey);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await _checkTaskReminders();
      return Future.value(true);
    } catch (e) {
      log('Error in background task: $e');
      return Future.value(false);
    }
  });
}

Future<void> _checkTaskReminders() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('todos') ?? '[]';
    final todosList = json.decode(todosJson) as List;
    
    final todos = todosList.map((todo) => Todo.fromJson(todo)).toList();
    final now = DateTime.now();
    
    for (final todo in todos) {
      if (todo.reminderDate != null && !todo.isCompleted) {
        final reminderTime = todo.reminderDate!;
        
        // Verifica se o lembrete deve ser disparado (com tolerância de 1 minuto)
        final timeDifference = reminderTime.difference(now).inMinutes.abs();
        
        if (timeDifference <= 1) {
          // Verifica se já foi mostrado este lembrete
          final shownKey = 'shown_${todo.id}_${reminderTime.millisecondsSinceEpoch}';
          final alreadyShown = prefs.getBool(shownKey) ?? false;
          
          if (!alreadyShown) {
            // Marca como mostrado
            await prefs.setBool(shownKey, true);
            
            // Mostra a notificação de alarme
            final notificationService = NotificationService();
            await notificationService.initialize();
            await notificationService.showTaskAlarmNotification(
              taskId: todo.id,
              title: todo.title,
              description: todo.description,
            );
            
            // Salva o ID da tarefa que deve mostrar o alarme na tela
            await prefs.setString('pending_alarm_task', todo.id);
          }
        }
      }
    }
  } catch (e) {
    log('Error checking task reminders: $e');
  }
}
