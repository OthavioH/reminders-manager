import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/presentation/screens/todo_list/todo_list_controller.dart';
import 'package:reminder_manager/presentation/widgets/create_todo_modal/create_todo_modal.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => CreateTodoModal(
              onCreateTodo: (todo) {
                ref.invalidate(todoListProvider);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Builder(
        builder: (context) {
          final todosAsync = ref.watch(todoListProvider);
          return todosAsync.when(
            data: (todos) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card.filled(
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(todoListProvider.notifier)
                            .toggleTaskCompleted(todo.id);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    todo.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        ref
                                            .read(todoListProvider.notifier)
                                            .deleteTodo(todo.id);
                                      },
                                    ),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: Icon(
                                        todo.isCompleted
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(todoListProvider.notifier)
                                            .toggleTaskCompleted(todo.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Builder(
                              builder: (context) {
                                if (todo.reminderDate == null) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Builder(
                                    builder: (context) {
                                      final timeOfDay = TimeOfDay.fromDateTime(
                                        todo.reminderDate!,
                                      );
                                      final timeOfDayFormat =
                                          MaterialLocalizations.of(
                                            context,
                                          ).formatTimeOfDay(
                                            timeOfDay,
                                            alwaysUse24HourFormat: true,
                                          );
                                      final dateFormat =
                                          MaterialLocalizations.of(
                                            context,
                                          ).formatShortDate(todo.reminderDate!);
                                      return Text(
                                        '$dateFormat at $timeOfDayFormat',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                            ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            if (todo.description.isNotEmpty)
                              Text(
                                todo.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }
}
