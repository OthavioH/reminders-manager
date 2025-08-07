
class CreateTodoModel {
    final String title;
  final String description;
  final DateTime? reminderDate;
  final bool isCompleted;

  CreateTodoModel({
    required this.title,
    required this.description,
    this.reminderDate,
    this.isCompleted = false,
  });

  // Converte Todo para Map (para serialização JSON)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reminderDate': reminderDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Cria Todo a partir de Map (para deserialização JSON)
  factory CreateTodoModel.fromJson(Map<String, dynamic> json) {
    return CreateTodoModel(
      title: json['title'],
      description: json['description'],
      reminderDate: json['reminderDate'] != null 
          ? DateTime.parse(json['reminderDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}