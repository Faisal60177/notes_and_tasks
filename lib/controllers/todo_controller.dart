import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/database/db_helper.dart';
import 'package:notes_app/models/todo_model.dart';

class TodoController extends GetxController {
  final DbHelper _dbHelper = DbHelper();

  RxList<TodoModel> todos = <TodoModel>[].obs;
  RxList<TodoModel> filteredTodos = <TodoModel>[].obs;
  RxBool isSearching = false.obs;
  RxBool isLoading = false.obs;

  RxDouble completionRate = 0.0.obs;

  @override
  void onInit(){
    super.onInit();
    loadTodos();
  }

  Future<void> loadTodos() async{
    isLoading.value = true;
    todos.value = await _dbHelper.getAllTodos();
    _calculateCompletionRate();
    isLoading.value = false;
  }

  void _calculateCompletionRate(){
    if(todos.isEmpty){
      completionRate.value = 0.0;
      return;
    }
    int doneCount = todos.where((todo) => todo.isDone).length;
    completionRate.value = doneCount / todos.length;

  }

  Future<void> addTodo({
    required String title,
    required String description,
    required int priority,
    String? dueDate,

}) async {
    String now = DateFormat('dd MMM yyyy').format(DateTime.now());

    TodoModel newTodo = TodoModel(title: title, description: description, isDone: false, priority: priority, createdAt: now);
    await _dbHelper.insertTodo(newTodo);
    await loadTodos();

    Get.snackbar('Successful', 'Task added successfully',
    backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM

    );
  }

  Future<void> updateTodo({
    required TodoModel todo,
    required String title,
    required String description,
    required int priority,
    String? dueDate,
}) async {
    TodoModel updateTodo = TodoModel(id : todo.id, title: title, description: description, isDone: todo.isDone, priority: priority, dueDate: dueDate, createdAt: todo.createdAt);
    await _dbHelper.updateTodo(updateTodo);
    await loadTodos();
  }

  Future<void> toggleDone(TodoModel todo) async {
    await _dbHelper.toggleTodoDone(todo.id!, !todo.isDone);
    await loadTodos();
  }

  Future<void> deleteTodo(TodoModel todo) async {
    await _dbHelper.deleteNote(todo.id!);
    await loadTodos();

    Get.snackbar('task removed', '"${todo.title}" removed',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(onPressed: () async{
        await _dbHelper.insertTodo(TodoModel(
          title: todo.title,
          description: todo.description,
          isDone: false,
          priority: todo.priority,
          dueDate: todo.dueDate,
          createdAt: todo.createdAt
        ));
        await loadTodos();

      }, child: const Text('Undo', style: TextStyle(color: Colors.white))),
    );
  }

  Future<void> searchTodos(String keyword) async {
    if(keyword.isEmpty){
      isSearching.value = false;
      filteredTodos.clear();
      return;
    }
    isSearching.value = true;
    filteredTodos.value = await _dbHelper.searchTodos(keyword);

  }
  void clearSearch(){
    isSearching.value = false;
    filteredTodos.clear();
  }

  String getPriorityLabel(int priority){
    switch (priority){
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'sometimes';
      case 4: return 'low';
      default: return '';
    }

  }

  Color getPriorityColor(int priority){
    switch(priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }



}