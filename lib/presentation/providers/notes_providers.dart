import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/providers/core_providers.dart';
import 'package:NoteFlow/features/notes/data/datasources/note_local_datasource.dart';
import 'package:NoteFlow/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:NoteFlow/features/notes/data/repository/note_repository.dart';
import 'auth_notifier.dart';

part 'notes_providers.g.dart';

@Riverpod(keepAlive: true)
NoteLocalDatasource noteLocalDatasource(Ref ref) {
  return NoteLocalDatasource();
}

@Riverpod(keepAlive: true)
NoteRemoteDatasource noteRemoteDatasource(Ref ref) {
  final userId = ref.watch(
    authProvider.select((s) => s.isLoggedIn ? s.uid : 'guest'),
  );
  return NoteRemoteDatasource(userId: userId);
}

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  final isLoggedIn = ref.watch(authProvider.select((s) => s.isLoggedIn));
  final repository = NoteRepository(
    local: ref.watch(noteLocalDatasourceProvider),
    remote: ref.watch(noteRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    isLoggedIn: isLoggedIn,
  );
  ref.onDispose(() => repository.dispose());
  return repository;
}

