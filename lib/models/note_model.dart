class NoteModel{
  int? id;
  String title;
  String content;
  int color;
  String createdAt;
  String updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
});

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'title' : title,
      'content' : content,
      'color' : color,
      'createdAt' : createdAt,
      'updatedAt' : updatedAt,
    };
  }

  factory NoteModel.fromMap(Map<String,dynamic> map){
    return NoteModel(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        color: map['color'],
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt'],
    );
  }

}