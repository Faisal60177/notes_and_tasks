import 'package:flutter/material.dart';
import 'package:NoteFlow/features/todo/data/models/todo_model.dart';
import 'priority_badge.dart';

class TodoTile extends StatelessWidget {

  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = priorityColor(todo.priority);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Opacity(
              opacity: todo.isCompleted ? 0.6 : 1,
              child: ListTile(
                leading: Checkbox(value: todo.isCompleted, onChanged: (_) => onToggle()),
                title: Text(
                  todo.title,
                  style: TextStyle(decoration: todo.isCompleted ? TextDecoration.lineThrough : null),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: todo.isCompleted ? Colors.grey.shade300 : accentColor),
          ),
        ],
      ),
    );


  }
}