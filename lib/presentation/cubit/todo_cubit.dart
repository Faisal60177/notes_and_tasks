import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';
import 'package:notes_app/features/todo/data/repository/todo_repository.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState>{

  final TodoRepository _repository;

  TodoCubit(this._repository) : super(const TodoState()){
    _repository.startRemoteListener(_reloadFromLocal);
  }

  Future<void> loadTodos() async {
    emit(state.copyWith(status: TodoStatus.loading));
    try{
      final todos = await _repository.getTodos();
      emit(state.copyWith(status: TodoStatus.loaded, todos: todos));
      syncNow();
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addTodo({
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
}) async {
    await _repository.addTodo(
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
    );
    await _reloadFromLocal();
  }

  Future<void> toggleCompleted(TodoModel todo) async {
    await _repository.toggleCompleted(todo);
    await _reloadFromLocal();
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _repository.updateTodo(todo);
    await _reloadFromLocal();
  }

  Future<void> deleteTodo(TodoModel todo) async {
    await _repository.deleteTodo(todo);
    await _reloadFromLocal();
  }

  Future<void> syncNow() async {
    emit(state.copyWith(isSyncing: true));
    try {
      await _repository.syncNow();
    } finally {
      await _reloadFromLocal(isSyncing: false);
    }

  }

  Future<void> _reloadFromLocal({bool isSyncing = false}) async {
    final todos = await _repository.getTodos();
    emit(state.copyWith(status: TodoStatus.loaded,todos: todos, isSyncing: isSyncing));
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }

}