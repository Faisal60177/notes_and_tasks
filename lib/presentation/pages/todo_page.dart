import 'package:flutter/material.dart';
import '../widgets/todo_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';
import 'package:notes_app/presentation/providers/todo_notifier.dart';
import 'package:notes_app/presentation/widgets/add_edit_task_sheet.dart';

class TodoPage  extends ConsumerWidget{

  const TodoPage({super.key});
  
  void _openTaskSheet(BuildContext context, WidgetRef ref, {TodoModel? existingTodo}) {
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        builder: (_) => AddEditTaskSheet(
            existingTodo: existingTodo,
            onSubmit: ({required title, description, category, required priority, dueDate}){
              final notifier = ref.read(todoProvider.notifier);
              if(existingTodo == null){
                notifier.addTask(
                  title: title,
                  description: description,
                  category: category,
                  priority: priority,
                  dueDate: dueDate,
                );
              }else {
                notifier.updateTask(existingTodo.copyWith(
                  title: title,
                  description: description,
                  category: category,
                  priority: priority,
                  dueDate: dueDate,
                ));
              }
            },
            )
    );
  }

void _deleteWithUndo(BuildContext context, WidgetRef ref, TodoModel todo) {
  ref.read(todoProvider.notifier).deleteTask(todo);

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text('"${todo.title}" deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(todoProvider.notifier).restoreTask(todo),
        ),
  ),
  );
}
  
  
  
  

 
@override
Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task'),
        actions: [
          IconButton(
            icon: (todoAsync.value?.isSyncing ?? false)
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
          )
          : const Icon(Icons.sync),
            onPressed: ()=> ref.read(todoProvider.notifier).syncNow(),
          )
        ],
      ),
      body: todoAsync.when(loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (todoListState){
        final todos = todoListState.todos;
        if(todos.isEmpty){
          return const Center(child: Text('No tasks yet - add one!'));
        }
        return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index){
              final todo = todos[index];
              return TodoTile(todo: todo, onToggle: ()=> ref.read(todoProvider.notifier).toggleCompleted(todo), onEdit: ()=> _openTaskSheet(context, ref, existingTodo: todo), onDelete: () => _deleteWithUndo(context, ref, todo),
              );
            },
        );
      }
      ),

      floatingActionButton: FloatingActionButton(onPressed: () => _openTaskSheet(context,ref),
      child: const Icon(Icons.add),),
    );
}


}