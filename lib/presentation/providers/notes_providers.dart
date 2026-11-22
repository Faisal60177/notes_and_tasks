import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/constants/owner_ids.dart';
import 'package:NoteFlow/core/providers/core_providers.dart';
import 'package:NoteFlow/features/notes/data/datasources/note_local_datasource.dart';
import 'package:NoteFlow/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:NoteFlow/features/notes/data/repository/note_repository.dart';
import 'current_owner_provider.dart';

part 'notes_providers.g.dart';

@Riverpod(keepAlive: true)
NoteLocalDatasource noteLocalDatasource(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  return NoteLocalDatasource(ownerId: ownerId);
}

@Riverpod(keepAlive: true)
NoteRemoteDatasource noteRemoteDatasource(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  return NoteRemoteDatasource(userId: ownerId);
}

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  final ownerId = ref.watch(currentOwnerIdProvider);
  final repository = NoteRepository(
    local: ref.watch(noteLocalDatasourceProvider),
    remote: ref.watch(noteRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    isLoggedIn: ownerId != kGuestOwnerId,
  );
  ref.onDispose(repository.dispose);
  return repository;
}