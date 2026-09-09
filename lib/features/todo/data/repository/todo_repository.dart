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
    unawaited(_pushIfOnline(todo));
  }
  
  Future<void> updateTodo(TodoModel todo) async {
    final updated = todo.copyWith(updatedAt: DateTime.now(), isSynced: false);
    await _local.upsertTodo(updated);
    unawaited(_pushIfOnline(updated));
  }

  Future<void> toggleCompleted(TodoModel todo) =>
      updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));

  Future<void> deleteTodo(TodoModel todo) async {
    final now = DateTime.now();
    await _local.softDeleteTodo(todo.id, now);
    unawaited(_pushIfOnline(todo.copyWith(isDeleted: true, updatedAt: now)));
  }

  Future<void> restoreTodo(TodoModel todo) async {
    final now = DateTime.now();
    await _local.restoreTodo(todo.id, now);
    unawaited(_pushIfOnline(todo.copyWith(isDeleted: false, updatedAt: now)));
  }

  Future<void> _pushIfOnline(TodoModel todo) async {
    if(!isLoggedIn) return;
    if(await _connectivity.isOnline){
      await _remote.pushTodo(todo);
      await _local.markSynced(todo.id);
    }
  }

  Future<void> syncNow() async {
    if(!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;


    final unsynced = await _local.getUnsyncedTodos();
    for (final todo in unsynced) {
      await _remote.pushTodo(todo);
      await _local.markSynced(todo.id);
    }
    await _local.purgeSyncedDeletes();

    final remoteTodos = await _remote.fetchAllTodos();
    final localTodos = await _local.getAllTodos();
    final localById = {for(final t in localTodos) t.id: t};

    final toApply = <TodoModel>[];
    for (final remoteTodo in remoteTodos) {
      final localTodo = localById[remoteTodo.id];
      if (localTodo == null ||
          remoteTodo.updatedAt.isAfter(localTodo.updatedAt)) {
        toApply.add(remoteTodo);
      }

    }
    if (toApply.isNotEmpty) await _local.upsertMany(toApply);
  }

  void startRemoteListener(void Function() onChanged){
      _remoteSub?.cancel();
      if(!isLoggedIn) return;
      _remoteSub = _remote.watchTodos().listen((remoteTodos) async {
        final localTodos = await _local.getAllTodos();
        final localById = {for (final t in localTodos) t.id: t};
        final toApply = <TodoModel>[];
        for(final remoteTodo in remoteTodos){
          final localTodo = localById[remoteTodo.id];
          if(localTodo == null || remoteTodo.updatedAt.isAfter(localTodo.updatedAt)) {
            toApply.add(remoteTodo);
          }
        }
        if(toApply.isNotEmpty){
          await _local.upsertMany(toApply);
          onChanged();
        }
      });
  }

  void dispose() => _remoteSub?.cancel();

}