
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/data/repositories/local_todo_repository.dart';
import 'package:reminder_manager/domain/repositories/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return ref.watch(localTodoRepositoryProvider);
});