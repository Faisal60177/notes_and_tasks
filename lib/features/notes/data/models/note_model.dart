import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteColor { default_, red, orange, yellow, green, blue, purple, pink }

extension NoteColorX on NoteColor {
  String get storageValue => name;

  static NoteColor fromStorage(String? value) {
    return NoteColor.values.firstWhere(
          (c) => c.storageValue == value,
      orElse: () => NoteColor.default_,
    );
  }
}

class NoteModel {
  final String id;
  final String title;
  final String? content;
  final NoteColor color;
  final String? category;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  NoteModel({
    required this.id,
    required this.title,
    this.content,
    this.color = NoteColor.default_,
    this.category,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  NoteModel copyWith({
    String? title,
    String? content,
    NoteColor? color,
    String? category,
    bool? isPinned,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toSqliteMap() => {
    'id': id,
    'title': title,
    'content': content,
    'color': color.storageValue,
    'category': category,
    'isPinned': isPinned ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isSynced': isSynced ? 1 : 0,
    'isDeleted': isDeleted ? 1 : 0,
  };

  factory NoteModel.fromSqliteMap(Map<String, dynamic> map) => NoteModel(
    id: map['id'] as String,
    title: map['title'] as String,
    content: map['content'] as String?,
    color: NoteColorX.fromStorage(map['color'] as String?),
    category: map['category'] as String?,
    isPinned: (map['isPinned'] as int) == 1,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
    isSynced: (map['isSynced'] as int) == 1,
    isDeleted: (map['isDeleted'] as int) == 1,
  );

  Map<String, dynamic> toFirestoreMap() => {
    'title': title,
    'content': content,
    'color': color.storageValue,
    'category': category,
    'isPinned': isPinned,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isDeleted': isDeleted,
  };

  factory NoteModel.fromFirestore(String id, Map<String, dynamic> map) => NoteModel(
    id: id,
    title: map['title'] as String,
    content: map['content'] as String?,
    color: NoteColorX.fromStorage(map['color'] as String?),
    category: map['category'] as String?,
    isPinned: map['isPinned'] as bool? ?? false,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    isSynced: true,
    isDeleted: map['isDeleted'] as bool? ?? false,
  );
}
