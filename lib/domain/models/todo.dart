class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Todo markAsCompleted() {
    return copyWith(isCompleted: true, completedAt: DateTime.now());
  }

  Todo markAsIncomplete() {
    return copyWith(isCompleted: false, completedAt: null);
  }

  // Convert Todo object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create a Todo object from a JSON Map
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
    );
  }

  // Create a list of Todo objects from a list of JSON Maps
  static List<Todo> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  // Convert a list of Todo objects to a list of JSON Maps
  static List<Map<String, dynamic>> toJsonList(List<Todo> todos) {
    return todos.map((todo) => todo.toJson()).toList();
  }
}
