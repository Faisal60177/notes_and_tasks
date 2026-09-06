import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../cubit/todo_cubit.dart';
import '../cubit/todo_state.dart';
import '../widgets/todo_tile.dart';

class TodoPage  extends StatelessWidget{

  const TodoPage({super.key});

  void _showAddDialog(BuildContext context){
    final controller = TextEditingController();
    showDialog(context: context,
        builder: (dialogConext) => AlertDialog(
          title: const Text('New Task'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(dialogConext), child: const Text('Cancel'),),
            FilledButton(onPressed: (){
              if(controller.text.trim().isNotEmpty){
                context.read<TodoCubit>().addTodo(title: controller.text.trim());
              }
              Navigator.pop(dialogConext);
            }, child: const Text('Add'),)
          ],
        ));
  }


@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task'),
        actions: [
          BlocBuilder<TodoCubit, TodoState>(
            builder: (context, state) => IconButton(
              icon: state.isSyncing?
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),)
              : const Icon(Icons.sync),


              onPressed: () => context.read<TodoCubit>().syncNow(),),
          )
        ],
      ),
      body: BlocBuilder<TodoCubit, TodoState>(
          builder: (context,state){
            if(state.status == TodoStatus.loading){
              return const Center(child: CircularProgressIndicator(),);
            }
            if (state.status == TodoStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            if (state.todos.isEmpty) {
              return const Center(child: Text('No Task yet — add one!'));
            }
            
            return ListView.builder(
                itemCount: state.todos.length,
                
                itemBuilder: (context, index){
                  final todo = state.todos[index];
                  return TodoTile(
                      todo: todo, 
                      onToggle: ()=> context.read<TodoCubit>().toggleCompleted(todo),
                    onDelete: () => context.read<TodoCubit>().deleteTodo(todo),
                  );
                }
                );
          }
          ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context),
      child: const Icon(Icons.add),),
    );
}


}