import 'package:flutter/material.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';

class PriorityBadge  extends StatelessWidget{

  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  Color get _color{
    switch(priority){
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String get _label {
    switch(priority){
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }


@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _color, width: 1),
    ),
    child: Text(_label,style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600),),
  );
}
}