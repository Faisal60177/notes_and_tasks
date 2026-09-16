import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/features/notes/data/models/note_model.dart';
import 'notes_providers.dart';
import 'notes_state.dart';

part 'notes_notifier.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {

  bool _hasSyncedOnce = false;
  @override
  Future<NotesListState> build() async {
    final repository = ref.watch(noteRepositoryProvider);

    repository.startRemoteListener(() {
      ref.invalidateSelf();
    });

    if (!_hasSyncedOnce) {
      _hasSyncedOnce = true;
      Future.microtask(() => syncNow());
    }

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
    await repository.addNote(title: title, content: content, color: color, category: category);
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
    final current = state.value ?? const NotesListState();
    state = AsyncData(current.copyWith(isSyncing: true));

    final repository = ref.read(noteRepositoryProvider);
    try {
      await repository.syncNow();
    } finally {
      await _reload(isSyncing: false);
    }
  }

  Future<void> _reload({bool isSyncing = false}) async {
    final repository = ref.read(noteRepositoryProvider);
    final notes = await repository.getNotes();
    state = AsyncData(NotesListState(notes: notes, isSyncing: isSyncing));
  }
}
