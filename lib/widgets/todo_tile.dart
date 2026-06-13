import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../controllers/todo_controller.dart';

class TodoTile extends StatelessWidget {

  final TodoModel todo;
  final TodoController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;


  const TodoTile({
    super.key,
    required this.todo,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

@override
Widget build(BuildContext context) {

// Priority color ও label controller থেকে নাও
Color priorityColor = controller.getPriorityColor(todo.priority);
String priorityLabel = controller.getPriorityLabel(todo.priority);


return Dismissible(
  // Dismissible — swipe then will  delete widget
  key: Key(todo.id.toString()), // every item unique key need
  direction: DismissDirection.endToStart, // right to left swipe
  background: Container(
    // if swipe then show this background
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (_) => onDelete(), // swipe end then this will delete
  child: Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: ListTile(
      // ListTile — icon + text + trailing widget that  ready-made layout

      // to left priority color indicator
      leading: Container(
        width: 5,
        height: 50,
        decoration: BoxDecoration(
          color: priorityColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Checkbox
      // todo.isDone true then checked, false then unchecked
      title: Row(
        children: [
          Checkbox(
            value: todo.isDone,
            onChanged: (_) => controller.toggleDone(todo),
            activeColor: Colors.green,
          ),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                // if done line-through decoration
                decoration: todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isDone ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todo.description.isNotEmpty)
            Text(todo.description, maxLines: 1, overflow: TextOverflow.ellipsis),

          const SizedBox(height: 4),

          Row(
            children: [
              // Priority badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priorityLabel,
                  style: TextStyle(fontSize: 11, color: priorityColor),
                ),
              ),

              // Due date (if there)
              if (todo.dueDate != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 2),
                Text(
                  todo.dueDate!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),

      // to right edit button
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    ),
  ),
);
}
}

