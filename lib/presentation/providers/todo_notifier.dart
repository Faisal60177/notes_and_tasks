import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/providers/core_providers.dart';
import 'package:NoteFlow/features/todo/data/models/todo_model.dart';
import 'package:NoteFlow/features/todo/data/repository/todo_repository.dart';
import 'todo_providers.dart';
import 'todo_state.dart';

part 'todo_notifier.g.dart';

@Riverpod(keepAlive: true)
class TodoNotifier extends _$TodoNotifier {
  TodoRepository? _syncedRepo;
  TodoRepository? _syncingRepo;

  @override
  Future<TodoListState> build() async {
    final repository = ref.watch(todoRepositoryProvider);

    repository.startRemoteListener(() {
      unawaited(_reload());
    });

    ref.listen(connectivityStatusProvider, (_, next) {
      if (next.value == true) unawaited(syncNow());
    });

    if (!identical(_syncedRepo, repository)) {
      _syncedRepo = repository;
      Future.microtask(syncNow);
    }

    await repository.adoptGuestData();
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
    final repository = ref.read(todoRepositoryProvider);
    if (!repository.isLoggedIn || identical(_syncingRepo, repository)) return;
    _syncingRepo = repository;
    try {
      final current = state.value ?? await future;
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isSyncing: true));
      await repository.syncNow();
    } catch (_) {
    } finally {
      if (identical(_syncingRepo, repository)) _syncingRepo = null;
      if (ref.mounted) await _reload(isSyncing: false);
    }
  }

  Future<void> _reload({bool isSyncing = false}) async {
    final repository = ref.read(todoRepositoryProvider);
    final todos = await repository.getTodos();
    if (!ref.mounted) return;
    state = AsyncData(TodoListState(todos: todos, isSyncing: isSyncing));
  }
}