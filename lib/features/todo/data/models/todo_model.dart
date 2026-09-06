import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isSynced;
  final bool isDeleted;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.category,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
});

  TodoModel copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    String? category,
    DateTime? dueDate,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
}) {
    return TodoModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        category: category ?? this.category,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toSqfliteMap() => {
    'id' : id,
    'title' : title,
    'description' : description,
    'isCompleted' : isCompleted,
    'category' : category,
    'dueDate' : dueDate?.toIso8601String(),
    'createdAt' : createdAt.toIso8601String(),
    'updatedAt' : updatedAt.toIso8601String(),
    'isSynced' : isSynced ? 1 : 0,
    'isDeleted' : isDeleted ? 1 : 0,
  };

  factory TodoModel.fromSqfliteMap(Map<String, dynamic> map) => TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted:  (map['isCompleted'] as int) == 1,
      category: map['category'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    isSynced: (map['isSynced'] as int) == 1,
    isDeleted: (map['isDeleted'] as int) == 1,
  );

  Map<String, dynamic> toFirestoreMap() => {
    'title' : title,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isDeleted': isDeleted,
  };

  factory TodoModel.fromFirestore(String id, Map<String, dynamic> map) =>
      TodoModel(
          id: id,
          title: map['title'] as String,
          description: map['description'] as String?,
          isCompleted: map['isCompleted'] as bool? ?? false,
          category: map['category'] as String?,
          dueDate: (map['dueDate'] as Timestamp?) ?.toDate(),
          createdAt: (map['createdAt'] as Timestamp).toDate(),
          updatedAt: (map['updatedAt'] as Timestamp).toDate(),
          isSynced: true,
          isDeleted: map['isDeleted'] as bool? ?? false,
      );

}