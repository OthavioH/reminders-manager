import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/data/services/notification_service.dart';

class WindowsBackgroundService {
  static Timer? _timer;
  static bool _isRunning = false;

  static void startTaskChecker() {
    if (_isRunning) return;
    
    _isRunning = true;
    log('Starting Windows background task checker...');
    
    // Verifica imediatamente e depois a cada 30 segundos
    _checkTaskReminders();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkTaskReminders();
    });
  }

  static void stopTaskChecker() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    log('Stopped Windows background task checker');
  }

  static Future<void> _checkTaskReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString('todos') ?? '[]';
      final todosList = json.decode(todosJson) as List;
      
      final todos = todosList.map((todo) => Todo.fromJson(todo)).toList();
      final now = DateTime.now();
      
      for (final todo in todos) {
        if (todo.reminderDate != null && !todo.isCompleted) {
          final reminderTime = todo.reminderDate!;
          
          // Verifica se o lembrete deve ser disparado (com tolerância de 30 segundos)
          final timeDifference = reminderTime.difference(now).inMinutes.abs();
          
          if (timeDifference == 0) {
            // Verifica se já foi mostrado este lembrete
            final shownKey = 'shown_${todo.id}_${reminderTime.millisecondsSinceEpoch}';
            final alreadyShown = prefs.getBool(shownKey) ?? false;
            
            if (!alreadyShown) {
              // Marca como mostrado
              await prefs.setBool(shownKey, true);
              
              // Mostra a notificação de alarme
              final notificationService = NotificationService();
              await notificationService.showTaskAlarmNotification(
                taskId: todo.id,
                title: todo.title,
                description: todo.description,
              );
              
              // Salva o ID da tarefa que deve mostrar o alarme na tela
              await prefs.setString('pending_alarm_task', todo.id);
              
              log('🔔 Windows alarm triggered for: ${todo.title}');
            }
          }
        }
      }
    } catch (e) {
      log('Error checking task reminders on Windows: $e');
    }
  }
}
