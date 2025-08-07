
class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime? reminderDate;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.reminderDate,
    this.isCompleted = false,
  });

  // Converte Todo para Map (para serialização JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminderDate': reminderDate?.toUtc().toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Cria Todo a partir de Map (para deserialização JSON)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate']).toLocal()
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}