import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/todo_controller.dart';
import '../../widgets/todo_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_todo_screen.dart';

class TodoListScreen extends StatelessWidget {

  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.find<TodoController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),

      body: Obx(() {

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        List todos = controller.isSearching.value
            ? controller.filteredTodos
            : controller.todos;

        return Column(
          children: [

            // Completion progress bar
            if (!controller.isSearching.value && controller.todos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      '${(controller.completionRate.value * 100).toInt()}% completed',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                    const SizedBox(height: 6),
                    Obx(() => LinearProgressIndicator(
                      // LinearProgressIndicator — progress দেখানোর built-in widget
                      value: controller.completionRate.value,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.completionRate.value == 1.0
                            ? Colors.green // সব শেষ হলে সবুজ
                            : Colors.blue,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    )),
                  ],
                ),
              ),

            // Todo list
            Expanded(
              child: todos.isEmpty
                  ? EmptyState(
                icon: controller.isSearching.value
                    ? Icons.search_off
                    : Icons.checklist,
                message: controller.isSearching.value
                    ? 'No tasks found'
                    : 'No tasks yet\nTap + to add a new task',
              )
                  : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  return TodoTile(
                    todo: todos[index],
                    controller: controller,
                    onEdit: () => Get.to(
                          () => AddEditTodoScreen(existingTodo: todos[index]),
                    ),
                    onDelete: () => controller.deleteTodo(todos[index]),
                  );
                },
              ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditTodoScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, TodoController controller) {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          controller: searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search by title...'),
          onChanged: (v) => controller.searchTodos(v),
        ),
        actions: [
          TextButton(
            onPressed: () { controller.clearSearch(); Get.back(); },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}