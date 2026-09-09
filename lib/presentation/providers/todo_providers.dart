import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/presentation/providers/auth_notifier.dart';
import '../../../../core/providers/core_providers.dart';
import 'package:notes_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:notes_app/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:notes_app/features/todo/data/repository/todo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart';

@Riverpod(keepAlive: true)
TodoLocalDatasource todoLocalDatasource(Ref ref) {
  return TodoLocalDatasource();
}

@Riverpod(keepAlive: true)
TodoRemoteDatasource todoRemoteDatasource(Ref ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.isLoggedIn ? authState.uid : 'guest';
  return TodoRemoteDatasource(userId: userId);
}

@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;
  final repository = TodoRepository(
    local: ref.watch(todoLocalDatasourceProvider),
    remote: ref.watch(todoRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    isLoggedIn: isLoggedIn,
  );
  ref.onDispose(() => repository.dispose());
  return repository;
}