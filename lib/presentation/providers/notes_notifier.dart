import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/providers/core_providers.dart';
import 'package:NoteFlow/features/notes/data/models/note_model.dart';
import 'package:NoteFlow/features/notes/data/repository/note_repository.dart';
import 'notes_providers.dart';
import 'notes_state.dart';

part 'notes_notifier.g.dart';

@Riverpod(keepAlive: true)
class NotesNotifier extends _$NotesNotifier {
  NoteRepository? _syncedRepo;
  NoteRepository? _syncingRepo;

  @override
  Future<NotesListState> build() async {
    final repository = ref.watch(noteRepositoryProvider);

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
    final notes = await repository.getNotes();
    return NotesListState(notes: notes);
  }

  Future<void> addNote({
    required String title,
    String? content,
    NoteColor color = NoteColor.default_,
    String? category,
  }) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.addNote(
      title: title,
      content: content,
      color: color,
      category: category,
    );
    await _reload();
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.updateNote(updatedNote);
    await _reload();
  }

  Future<void> togglePinned(NoteModel note) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.togglePinned(note);
    await _reload();
  }

  Future<void> deleteNote(NoteModel note) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.deleteNote(note);
    await _reload();
  }

  Future<void> undoDelete(NoteModel note) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.undoDelete(note);
    await _reload();
  }

  Future<void> syncNow() async {
    final repository = ref.read(noteRepositoryProvider);
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
    final repository = ref.read(noteRepositoryProvider);
    final notes = await repository.getNotes();
    if (!ref.mounted) return;
    state = AsyncData(NotesListState(notes: notes, isSyncing: isSyncing));
  }
}