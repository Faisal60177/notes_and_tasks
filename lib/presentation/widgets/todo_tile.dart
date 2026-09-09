import 'package:flutter/material.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';
import 'priority_badge.dart';
class TodoTile extends StatelessWidget{

  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const  TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
});

@override
Widget build(BuildContext context) {
  return ListTile(
    leading: Checkbox(value: todo.isCompleted, onChanged: (_) => onToggle()),
    title: Text(
      todo.title,
      style: TextStyle(
        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (todo.description != null && todo.description!.isNotEmpty)
            Text(todo.description!, style: const TextStyle(fontSize: 13)),
          PriorityBadge(priority: todo.priority),
          if (todo.category != null && todo.category!.isNotEmpty)
            Chip(
              label: Text(todo.category!, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          if (todo.dueDate != null)
            Text(
              'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          if (!todo.isSynced)
            const Icon(Icons.cloud_off, size: 14, color: Colors.grey),
        ],
      ),
    ),
    isThreeLine: false,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ],
    ),
  );

}

}