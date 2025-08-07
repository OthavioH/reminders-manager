
import 'package:flutter/material.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/presentation/screens/task_alarm/task_alarm_screen.dart';
import 'package:reminder_manager/presentation/screens/todo_list/todo_list_screen.dart';

class AppRouter {
  
  static const String initialRoute = '/';
  static const String alarmRoute = '/alarm';

  static Map<String, WidgetBuilder> routes = {
    initialRoute: (context) => const TodoListScreen(),
    alarmRoute: (context) {
      final task = ModalRoute.of(context)!.settings.arguments as Todo;
      return TaskAlarmScreen(task: task);
    },
  };
}