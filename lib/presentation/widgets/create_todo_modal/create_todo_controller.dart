import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/data/providers/todo_repository_provider.dart';
import 'package:reminder_manager/domain/models/create_todo_model.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/domain/repositories/todo_repository.dart';

final createTodoControllerProvider =
    ChangeNotifierProvider.autoDispose<CreateTodoController>((ref) {
      return CreateTodoController(ref.read(todoRepositoryProvider));
    });

class CreateTodoController extends ChangeNotifier {
  final TodoRepository _todoRepository;

  CreateTodoController(this._todoRepository);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;

  set selectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> createTodo({
    void Function(Todo todo)? onCreateTodo,
    void Function(String errorMessage)? onError,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading = true;
        errorMessage = null; // Clear previous errors
        notifyListeners();

        final createdTodo = await _todoRepository.addTodo(
          CreateTodoModel(
            title: titleController.text,
            description: descriptionController.text,
            reminderDate: selectedDate,
          ),
        );
        
        onCreateTodo?.call(createdTodo);
      } catch (e) {
        // Handle different types of errors with user-friendly messages
        String errorMsg;
        if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMsg = 'Erro de conexão. Verifique sua internet e tente novamente.';
        } else if (e.toString().contains('permission') || e.toString().contains('access')) {
          errorMsg = 'Permissão negada. Verifique as permissões do app.';
        } else if (e.toString().contains('storage') || e.toString().contains('database')) {
          errorMsg = 'Erro de armazenamento. Tente novamente.';
        } else {
          errorMsg = 'Falha ao criar a tarefa. Tente novamente.';
        }
        
        errorMessage = errorMsg;
        onError?.call(errorMsg);
        
        // Log the actual error for debugging
        debugPrint('CreateTodo error: $e');
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
