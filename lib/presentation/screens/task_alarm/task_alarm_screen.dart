import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/domain/models/todo.dart';
import 'package:reminder_manager/presentation/screens/todo_list/todo_list_controller.dart';
import 'package:reminder_manager/data/services/notification_service.dart';

class TaskAlarmScreen extends ConsumerStatefulWidget {
  final Todo task;

  const TaskAlarmScreen({super.key, required this.task});

  @override
  ConsumerState<TaskAlarmScreen> createState() => _TaskAlarmScreenState();
}

class _TaskAlarmScreenState extends ConsumerState<TaskAlarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _markAsCompleted() async {
    await ref.read(todoListProvider.notifier).toggleTaskCompleted(widget.task.id);
    await NotificationService().cancelNotification(widget.task.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _snoozeTask() async {
    // Adia a tarefa por 5 minutos
    final newReminderDate = DateTime.now().add(const Duration(minutes: 5));
    await ref
        .read(todoListProvider.notifier)
        .updateTodoReminderDate(widget.task.id, newReminderDate);
    await NotificationService().cancelNotification(widget.task.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _dismissAlarm() async {
    await NotificationService().cancelNotification(widget.task.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: ListView(
          children: [
            // Botão de fechar no topo
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  onPressed: _dismissAlarm,
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone animado de alarme
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.alarm,
                              size: 60,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
            
                    const SizedBox(height: 40),
            
                    // Título do alarme
                    const Text(
                      'LEMBRETE DE TAREFA!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
            
                    const SizedBox(height: 32),
            
                    // Título da tarefa
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.task.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.task.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 48),
            
                    // Botões de ação
                    Column(
                      children: [
                        // Botão Marcar como Concluída
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _markAsCompleted,
                            icon: const Icon(Icons.check_circle, size: 24),
                            label: const Text(
                              'Marcar como Concluída',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 16),
            
                        // Botão Adiar 5 minutos
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _snoozeTask,
                            icon: const Icon(Icons.snooze, size: 24),
                            label: const Text(
                              'Adiar por 5 minutos',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 16),
            
                        // Botão Dispensar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _dismissAlarm,
                            icon: const Icon(Icons.close, size: 24),
                            label: const Text(
                              'Dispensar',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
