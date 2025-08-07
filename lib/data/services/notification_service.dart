import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder_manager/data/services/windows_notification_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (Platform.isWindows) {
      await WindowsNotificationService.initialize();
      return;
    }

    // Configuração para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuração para Darwin (macOS/iOS)
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permissões
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Quando a notificação for tocada, vamos navegar para a tela de alarme
    // Isso será implementado junto com o sistema de navegação
    log('Notification tapped: ${response.payload}');
  }

  Future<void> showTaskAlarmNotification({
    required String taskId,
    required String title,
    required String description,
  }) async {
    if (Platform.isWindows) {
      await WindowsNotificationService.showTaskNotification(
        title: 'Lembrete de Tarefa!',
        description: '$title - $description',
        taskId: taskId,
      );
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_alarms',
      'Task Alarms',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      autoCancel: false,
      ongoing: true,
      playSound: true,
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          'mark_done',
          'Marcar como Concluída',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        AndroidNotificationAction(
          'snooze',
          'Adiar 5min',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ],
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      taskId.hashCode,
      'Lembrete de Tarefa!',
      '$title - $description',
      notificationDetails,
      payload: taskId,
    );
  }

  Future<void> cancelNotification(String taskId) async {
    if (Platform.isWindows) {
      await WindowsNotificationService.cancelNotification(taskId);
      return;
    }
    
    await _notifications.cancel(taskId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    if (Platform.isWindows) {
      // Para Windows, vamos cancelar individualmente se necessário
      return;
    }
    
    await _notifications.cancelAll();
  }
}
