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
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity;

  Future<List<TodoModel>> getTodos() => _local.getAllTodos();

  Future<void> adoptGuestData() async {
    if (!isLoggedIn) return;
    await _local.adoptGuestRows();
  }

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
    unawaited(_push(todo));
  }

  Future<void> updateTodo(TodoModel todo) async {
    final updated = todo.copyWith(updatedAt: DateTime.now(), isSynced: false);
    await _local.upsertTodo(updated);
    unawaited(_push(updated));
  }

  Future<void> toggleCompleted(TodoModel todo) =>
      updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));

  Future<void> deleteTodo(
      TodoModel todo, {
        Duration undoWindow = const Duration(seconds: 5),
      }) async {
    final deletedAt = DateTime.now();
    await _local.softDeleteTodo(todo.id, deletedAt);

    final tombstone =
    todo.copyWith(isDeleted: true, updatedAt: deletedAt, isSynced: false);

    _pendingDeleteTimers[todo.id]?.cancel();
    _pendingDeleteTimers[todo.id] = Timer(undoWindow, () {
      _pendingDeleteTimers.remove(todo.id);
      _finalizeDelete(tombstone);
    });
  }

  Future<void> _finalizeDelete(TodoModel tombstone) async {
    if (!isLoggedIn) {
      await _local.deleteTodo(tombstone.id);
      return;
    }
    if (await _push(tombstone)) {
      await _local.purgeSyncedDeletes();
    }
  }

  Future<void> undoDelete(TodoModel todo) async {
    _pendingDeleteTimers.remove(todo.id)?.cancel();
    final now = DateTime.now();
    await _local.restoreTodo(todo.id, now);
    unawaited(
      _push(todo.copyWith(isDeleted: false, isSynced: false, updatedAt: now)),
    );
  }

  Future<bool> _push(TodoModel todo) async {
    if (!isLoggedIn) return false;
    if (!await _connectivity.isOnline) return false;
    return _pushOne(todo);
  }

  Future<bool> _pushOne(TodoModel todo) async {
    try {
      await _remote.pushTodo(todo);
      await _local.markSynced(todo.id, todo.updatedAt);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncNow() async {
    if (!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;

    final unsynced = await _local.getUnsyncedTodos();
    for (final todo in unsynced) {
      await _pushOne(todo);
    }
    await _local.purgeSyncedDeletes();

    final remoteTodos = await _remote.fetchAllTodos();
    final toApply = await _resolveConflicts(remoteTodos);
    if (toApply.isNotEmpty) await _local.upsertMany(toApply);
  }

  void Function()? _onChanged;
  void startRemoteListener(void Function() onChanged) {
    _onChanged = onChanged;
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
    final localById = {for (final t in localTodos) t.id: t};
    return [
      for (final r in remoteTodos)
        if (_shouldApply(r, localById[r.id])) r,
    ];
  }

  bool _shouldApply(TodoModel remote, TodoModel? local) {
    if (local == null) return !remote.isDeleted;
    return remote.updatedAt.isAfter(local.updatedAt);
  }
}