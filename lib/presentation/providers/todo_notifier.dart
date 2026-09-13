import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';
import 'todo_providers.dart';
import 'todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_notifier.g.dart';

@riverpod
class TodoNotifier extends _$TodoNotifier {

  bool _hasSyncedOnce = false;
  @override
  Future<TodoListState> build() async {
    final repository = ref.watch(todoRepositoryProvider);

    repository.startRemoteListener(() {
      ref.invalidateSelf();
    });

    if (!_hasSyncedOnce) {
      _hasSyncedOnce = true;
      Future.microtask(() => syncNow());
    }

    final todos = await repository.getTodos();
    return TodoListState(todos: todos);
  }

  Future<void> addTask({
    required String title,
    String? description,
    String? category,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.addTodo(
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
    );
    await _reload();
  }

  Future<void> updateTask(TodoModel updatedTodo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.updateTodo(updatedTodo);
    await _reload();
  }

  Future<void> toggleCompleted(TodoModel todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.toggleCompleted(todo);
    await _reload();
  }

  Future<void> deleteTask(TodoModel todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.deleteTodo(todo);
    await _reload();
  }

  Future<void> undoDelete(TodoModel todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.undoDelete(todo);
    await _reload();
  }

  Future<void> syncNow() async {
    final current = state.value ?? const TodoListState();
    state = AsyncData(current.copyWith(isSyncing: true));

    final repository = ref.read(todoRepositoryProvider);
    try {
      await repository.syncNow();
    } finally {
      await _reload(isSyncing: false);
    }
  }

  Future<void> _reload({bool isSyncing = false}) async {
    final repository = ref.read(todoRepositoryProvider);
    final todos = await repository.getTodos();
    state = AsyncData(TodoListState(todos: todos, isSyncing: isSyncing));
  }
}