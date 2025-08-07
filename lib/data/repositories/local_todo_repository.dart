
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/domain/models/create_todo_model.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/domain/repositories/todo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final localTodoRepositoryProvider = Provider<LocalTodoRepository>((ref) {
  return LocalTodoRepository(ref);
});

class LocalTodoRepository implements TodoRepository{
  final Ref ref;
  static const String _todosKey = 'todos';

  LocalTodoRepository(this.ref);

  Future<SharedPreferences> get _sharedPreferences async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<Todo> addTodo(CreateTodoModel createTodoModel) async {
    final prefs = await _sharedPreferences;
    final todos = await getTodos();
    final todo = Todo(
      id: const Uuid().v4(),
      title: createTodoModel.title,
      description: createTodoModel.description,
      reminderDate: createTodoModel.reminderDate,
      isCompleted: createTodoModel.isCompleted,
    );
    todos.add(todo);
    
    final todosJson = todos.map((t) => t.toJson()).toList();
    await prefs.setString(_todosKey, jsonEncode(todosJson));
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final prefs = await _sharedPreferences;
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    
    final todosJson = todos.map((t) => t.toJson()).toList();
    await prefs.setString(_todosKey, jsonEncode(todosJson));
  }

  @override
  Future<List<Todo>> getTodos() async {
    final prefs = await _sharedPreferences;
    final todosString = prefs.getString(_todosKey);
    
    if (todosString == null) {
      return [];
    }
    
    final todosList = jsonDecode(todosString) as List;
    return todosList.map((json) => Todo.fromJson(json)).toList();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final prefs = await _sharedPreferences;
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t.id == todo.id);
    
    if (index != -1) {
      todos[index] = todo;
      final todosJson = todos.map((t) => t.toJson()).toList();
      await prefs.setString(_todosKey, jsonEncode(todosJson));
    }
  }
  
}