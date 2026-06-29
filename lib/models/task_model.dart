class TaskModel {
  final int? id;
  final String title;
  final String description;
  final bool isDone;
  final String createdAt;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      isDone: map['isDone'] == 1,
      createdAt: map['createdAt'] as String,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    String? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
