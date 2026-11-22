import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/constants/owner_ids.dart';
import 'package:NoteFlow/core/providers/core_providers.dart';
import 'package:NoteFlow/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:NoteFlow/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:NoteFlow/features/todo/data/repository/todo_repository.dart';
import 'current_owner_provider.dart';

part 'todo_providers.g.dart';

@Riverpod(keepAlive: true)
TodoLocalDatasource todoLocalDatasource(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  return TodoLocalDatasource(ownerId: ownerId);
}

@Riverpod(keepAlive: true)
TodoRemoteDatasource todoRemoteDatasource(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  return TodoRemoteDatasource(userId: ownerId);
}

@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  final repository = TodoRepository(
    local: ref.watch(todoLocalDatasourceProvider),
    remote: ref.watch(todoRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    isLoggedIn: ownerId != kGuestOwnerId,
  );
  ref.onDispose(repository.dispose);
  return repository;
}