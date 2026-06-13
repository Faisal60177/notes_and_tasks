import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';

class TodoController extends GetxController {
  final DbHelper _dbHelper = DbHelper();

  RxList<TodoModel> todos = <TodoModel>[].obs;
  RxList<TodoModel> filteredTodos = <TodoModel>[].obs;
  RxBool isSearching = false.obs;
  RxBool isLoading = false.obs;
  RxDouble completionRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  // Load all todos from database
  Future<void> loadTodos() async {
    try {
      isLoading.value = true;
      todos.value = await _dbHelper.getAllTodos();
      _calculateCompletionRate();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tasks: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate how many tasks are done
  void _calculateCompletionRate() {
    if (todos.isEmpty) {
      completionRate.value = 0.0;
      return;
    }
    int doneCount = todos.where((todo) => todo.isDone).length;
    completionRate.value = doneCount / todos.length;
  }

  // Add new task
  Future<void> addTodo({
    required String title,
    required String description,
    required int priority,
    String? dueDate,
  }) async {
    try {
      String now = DateFormat('dd MMM yyyy').format(DateTime.now());
      TodoModel newTodo = TodoModel(
        title: title,
        description: description,
        isDone: false,
        priority: priority,
        dueDate: dueDate,
        createdAt: now,
      );
      await _dbHelper.insertTodo(newTodo);
      await loadTodos();
      Get.snackbar(
        'Success', 'Task added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update existing task
  Future<void> updateTodo({
    required TodoModel todo,
    required String title,
    required String description,
    required int priority,
    String? dueDate,
  }) async {
    try {
      TodoModel updatedTodo = TodoModel(
        id: todo.id,
        title: title,
        description: description,
        isDone: todo.isDone,
        priority: priority,
        dueDate: dueDate,
        createdAt: todo.createdAt,
      );
      await _dbHelper.updateTodo(updatedTodo);
      await loadTodos();
      Get.snackbar(
        'Success', 'Task updated successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle task done or undone
  Future<void> toggleDone(TodoModel todo) async {
    await _dbHelper.toggleTodoDone(todo.id!, !todo.isDone);
    await loadTodos();
  }

  // Delete task with undo option
  Future<void> deleteTodo(TodoModel todo) async {
    try {
      await _dbHelper.deleteTodo(todo.id!);
      await loadTodos();
      Get.snackbar(
        'Deleted', '"${todo.title}" deleted',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () async {
            await _dbHelper.insertTodo(TodoModel(
              title: todo.title,
              description: todo.description,
              isDone: false,
              priority: todo.priority,
              dueDate: todo.dueDate,
              createdAt: todo.createdAt,
            ));
            await loadTodos();
          },
          child: const Text('Undo', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Search tasks by keyword
  Future<void> searchTodos(String keyword) async {
    if (keyword.isEmpty) {
      isSearching.value = false;
      filteredTodos.clear();
      return;
    }
    isSearching.value = true;
    filteredTodos.value = await _dbHelper.searchTodos(keyword);
  }

  // Clear search
  void clearSearch() {
    isSearching.value = false;
    filteredTodos.clear();
  }

  // Get priority label text
  String getPriorityLabel(int priority) {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'Low';
      default: return 'Medium';
    }
  }

  // Get priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }
}