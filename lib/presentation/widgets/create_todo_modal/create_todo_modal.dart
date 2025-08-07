import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/presentation/widgets/create_todo_modal/create_todo_controller.dart';

class CreateTodoModal extends ConsumerStatefulWidget {
  final void Function(Todo)? onCreateTodo;
  const CreateTodoModal({required this.onCreateTodo, super.key});

  @override
  ConsumerState<CreateTodoModal> createState() => _CreateTodoModalState();
}

class _CreateTodoModalState extends ConsumerState<CreateTodoModal> {
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text('Erro'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear the error from controller
                ref.read(createTodoControllerProvider).clearError();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Create Todo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Form(
          key: ref.watch(createTodoControllerProvider).formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: ref
                    .watch(createTodoControllerProvider)
                    .titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ref
                    .watch(createTodoControllerProvider)
                    .descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Reminder Date & Time',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(3000),
                  );

                  if (selectedDate != null && context.mounted) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        DateTime.now().add(const Duration(minutes: 1)),
                      ),
                    );

                    if (selectedTime != null) {
                      final combinedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      ref.read(createTodoControllerProvider).selectedDate =
                          combinedDateTime;
                    }
                  }
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Builder(
                    builder: (context) {
                      final selectedDate = ref
                          .watch(createTodoControllerProvider)
                          .selectedDate;
                      return Text(
                        selectedDate != null
                            ? '${MaterialLocalizations.of(context).formatShortDate(selectedDate)} at ${TimeOfDay.fromDateTime(selectedDate).format(context)}'
                            : 'Select Date & Time',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () async {
            final controller = ref.read(createTodoControllerProvider);
            
            await controller.createTodo(
              onCreateTodo: (todo) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tarefa criada com sucesso!'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                
                widget.onCreateTodo?.call(todo);
                Navigator.of(context).pop();
              },
              onError: (errorMessage) {
                // Show error dialog
                _showErrorDialog(errorMessage);
              },
            );
          },
          child: Builder(
            builder: (context) {
              final isLoading = ref
                  .watch(createTodoControllerProvider)
                  .isLoading;
              if (isLoading) {
                return SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              }
              return const Text('Create');
            },
          ),
        ),
      ],
    );
  }
}
