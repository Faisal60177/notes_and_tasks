import 'package:flutter/material.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';

class TodoTile extends StatelessWidget{

  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const  TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
});

@override
Widget build(BuildContext context) {
  return ListTile(
    leading: Checkbox(value: todo.isCompleted, onChanged: (_) => onToggle()),
    title:  Text(todo.title,
    style: TextStyle(decoration: todo.isCompleted ? TextDecoration.lineThrough : null,),),
    subtitle: todo.description!= null ? Text(todo.description!) : null,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(!todo.isSynced)
          const Padding(padding: EdgeInsets.only(right: 6),
          child: Icon(Icons.cloud_off, size: 16, color: Colors.grey,),),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline))
      ],
    ),
  );

}

}