
import 'package:reminder_manager/domain/models/create_todo_model.dart';
import 'package:reminder_manager/domain/models/todo.dart';

abstract class TodoRepository {
  const TodoRepository();

  Future<List<Todo>> getTodos();

  Future<Todo> addTodo(CreateTodoModel createTodoModel);

  Future<void> updateTodo(Todo todo);

  Future<void> deleteTodo(String id);
}