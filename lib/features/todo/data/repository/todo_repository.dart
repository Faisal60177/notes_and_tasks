import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../core/services/connectivity_service.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepository {
  final TodoLocalDatasource _local;
  final TodoRemoteDatasource _remote;
  final ConnectivityService _connectivity;
  final bool isLoggedIn;
  StreamSubscription? _remoteSub;
  final Map<String, Timer> _pendingDeleteTimers = {};

  TodoRepository({
    required TodoLocalDatasource local,
    required TodoRemoteDatasource remote,
    required ConnectivityService connectivity,
    required this.isLoggedIn,
}) : _local = local,
  _remote = remote,
  _connectivity = connectivity;


  Future<List<TodoModel>> getTodos() => _local.getAllTodos();

  Future<void> addTodo({
    required String title,
    String? description,
    String? category,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
}) async {
    final now = DateTime.now();
    final todo = TodoModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
    );
    await _local.upsertTodo(todo);
    unawaited(_pushIfAllowed(todo));
  }
  
  Future<void> updateTodo(TodoModel todo) async {
    final updated = todo.copyWith(updatedAt: DateTime.now(), isSynced: false);
    await _local.upsertTodo(updated);
    unawaited(_pushIfAllowed(updated));
  }

  Future<void> toggleCompleted(TodoModel todo) =>
      updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));

  Future<void> deleteTodo(TodoModel todo, {
    Duration undoWindow = const Duration(seconds: 5),
  }) async {
    await _local.softDeleteTodo(todo.id, DateTime.now());
    _pendingDeleteTimers[todo.id]?.cancel();
    _pendingDeleteTimers[todo.id] = Timer(undoWindow, () {
    _pendingDeleteTimers.remove(todo.id);
    _finalizeDelete(todo.id);
    });
  }

  Future<void> _finalizeDelete(String id) async {
    if (isLoggedIn && await _connectivity.isOnline) {
      try {
        await _remote.deleteTodo(id);
      } catch (_) {
        return;
      }
      await _local.deleteTodo(id);
    }
  }



  Future<void> undoDelete(TodoModel todo) async {
    _pendingDeleteTimers.remove(todo.id)?.cancel();
    await _local.restoreTodo(todo.id, DateTime.now());
  }

  Future<void> _pushIfAllowed(TodoModel todo) async {
    if(!isLoggedIn) return;
    if(await _connectivity.isOnline){
      try {
        await _remote.pushTodo(todo);
        await _local.markSynced(todo.id);
      } catch (_) {
      }
    }
  }

  Future<void> syncNow() async {
    if (!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;
    final unsynced = await _local.getUnsyncedTodos();
    for (final todo in unsynced) {
      try {
        if (todo.isDeleted) {
          await _remote.deleteTodo(todo.id);
          await _local.deleteTodo(todo.id);
        } else {
          await _remote.pushTodo(todo);
          await _local.markSynced(todo.id);
        }
      } catch (_) {
        continue;
      }
    }
    await _local.purgeSyncedDeletes();
    final remoteTodos = await _remote.fetchAllTodos();
    final toApply = await _resolveConflicts(remoteTodos);
    if (toApply.isNotEmpty) await _local.upsertMany(toApply);
  }

  void startRemoteListener(void Function() onChanged) {
    _remoteSub?.cancel();
    if (!isLoggedIn) return;
    _remoteSub = _remote.watchTodos().listen((remoteTodos) async {
      final toApply = await _resolveConflicts(remoteTodos);
      if (toApply.isNotEmpty) {
        await _local.upsertMany(toApply);
        onChanged();
      }
    });
  }

  void dispose() {
    _remoteSub?.cancel();
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    _pendingDeleteTimers.clear();
  }

  Future<List<TodoModel>> _resolveConflicts(List<TodoModel> remoteTodos) async {
    final localTodos = await _local.getAllTodosIncludingDeleted();
    final localById = {for (final n in localTodos) n.id: n};
    return [
      for (final r in remoteTodos)
        if (localById[r.id] == null ||
            r.updatedAt.isAfter(localById[r.id]!.updatedAt))
          r,
    ];
  }

}