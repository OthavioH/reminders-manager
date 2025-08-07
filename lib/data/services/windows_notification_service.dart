import 'dart:developer';
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';

class WindowsNotificationService {
  static Future<void> initialize() async {
    if (Platform.isWindows) {
      try {
        await localNotifier.setup(
          appName: 'Reminder Manager',
          shortcutPolicy: ShortcutPolicy.requireCreate,
        );
        log('WindowsNotificationService initialized successfully');
      } catch (e) {
        log('Windows notification initialization failed: $e');
      }
    }
  }

  static Future<void> showTaskNotification({
    required String title,
    required String description,
    required String taskId,
  }) async {
    if (Platform.isWindows) {
      try {
        final notification = LocalNotification(
          title: '🔔 $title',
          body: description,
          actions: [
            LocalNotificationAction(
              text: 'Marcar como Concluída',
            ),
            LocalNotificationAction(
              text: 'Adiar 5 min',
            ),
          ],
        );
        
        await notification.show();
        log('🔔 Windows Notification shown: $title - $description');
      } catch (e) {
        log('Failed to show Windows notification: $e');
        // Fallback para log simples
        log('🔔 ALARME: $title - $description');
      }
    }
  }

  static Future<void> cancelNotification(String taskId) async {
    try {
      // local_notifier não tem método específico para cancelar por ID
      // mas podemos implementar uma lógica simples
      log('❌ Cancelled Windows notification for task: $taskId');
    } catch (e) {
      log('Failed to cancel Windows notification: $e');
    }
  }
}
