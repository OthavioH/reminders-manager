import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/data/providers/todo_repository_provider.dart';
import 'package:reminder_manager/domain/models/todo.dart';

final todoListProvider =
    AsyncNotifierProvider<TodoListController, List<Todo>>(
      TodoListController.new,
    );

class TodoListController extends AsyncNotifier<List<Todo>> {
  @override
  FutureOr<List<Todo>> build() {
    return ref.watch(todoRepositoryProvider).getTodos();
  }

  Future<void> deleteTodo(String id) async {
    await ref.watch(todoRepositoryProvider).deleteTodo(id);
    state = AsyncValue.data(
      state.value?.where((todo) => todo.id != id).toList() ?? [],
    );
  }

  Future<void> toggleTaskCompleted(String id) async {
    final currentTodos = state.value ?? [];
    final todoIndex = currentTodos.indexWhere((todo) => todo.id == id);
    
    if (todoIndex != -1) {
      final todo = currentTodos[todoIndex];
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        reminderDate: todo.reminderDate,
        isCompleted: !todo.isCompleted,
      );

      await ref.watch(todoRepositoryProvider).updateTodo(updatedTodo);

      final updatedTodos = [...currentTodos];
      updatedTodos[todoIndex] = updatedTodo;
      state = AsyncValue.data(updatedTodos);
    }
  }

  Future<void> updateTodoReminderDate(String id, DateTime newReminderDate) async {
    final currentTodos = state.value ?? [];
    final todoIndex = currentTodos.indexWhere((todo) => todo.id == id);

    if (todoIndex != -1) {
      final todo = currentTodos[todoIndex];
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        reminderDate: newReminderDate,
        isCompleted: todo.isCompleted,
      );

      await ref.watch(todoRepositoryProvider).updateTodo(updatedTodo);

      final updatedTodos = [...currentTodos];
      updatedTodos[todoIndex] = updatedTodo;
      state = AsyncValue.data(updatedTodos);
    }
  }
}
