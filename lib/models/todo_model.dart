class TodoModel {
  int? id;
  String title;
  String description;
  bool isDone;
  int priority;
  String? dueDate; // nullable
  String createdAt;

  TodoModel({
    this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.priority,
    this.dueDate,
    required this.createdAt,
  });

  // toMap() — to save in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone' : isDone ? 1 : 0,
      'priority': priority,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }

  // fromMap() — for read from Database
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone : map['isDone'] == 1,
      priority: map['priority'],
      dueDate: map['dueDate'],
      createdAt: map['createdAt'],
    );
  }
}