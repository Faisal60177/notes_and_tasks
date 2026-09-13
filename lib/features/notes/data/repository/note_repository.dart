import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:notes_app/core/services/connectivity_service.dart';
import '../datasources/note_local_datasource.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

class NoteRepository {
  final NoteLocalDatasource _local;
  final NoteRemoteDatasource _remote;
  final ConnectivityService _connectivity;
  final bool isLoggedIn;
  StreamSubscription? _remoteSub;
  final Map<String, Timer> _pendingDeleteTimers = {};

  NoteRepository({
    required NoteLocalDatasource local,
    required NoteRemoteDatasource remote,
    required ConnectivityService connectivity,
    required this.isLoggedIn,
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity;

  Future<List<NoteModel>> getNotes() => _local.getAllNotes();

  Future<void> addNote({
    required String title,
    String? content,
    NoteColor color = NoteColor.default_,
    String? category,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      color: color,
      category: category,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    await _local.upsertNote(note);
    unawaited(_pushIfAllowed(note));
  }

  Future<void> updateNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: DateTime.now(), isSynced: false);
    await _local.upsertNote(updated);
    unawaited(_pushIfAllowed(updated));
  }

  Future<void> togglePinned(NoteModel note) => updateNote(note.copyWith(isPinned: !note.isPinned));

  Future<void> deleteNote(
      NoteModel note, {
        Duration undoWindow = const Duration(seconds: 5),
      }) async {
    await _local.softDeleteNote(note.id, DateTime.now());
    _pendingDeleteTimers[note.id]?.cancel();
    _pendingDeleteTimers[note.id] = Timer(undoWindow, () {
      _pendingDeleteTimers.remove(note.id);
      _finalizeDelete(note.id);
    });
  }

  Future<void> _finalizeDelete(String id) async {
    if (isLoggedIn && await _connectivity.isOnline) {
      try {
        await _remote.deleteNote(id);
      } catch (_) {
        return;
      }
      await _local.deleteNote(id);
    }
  }

  Future<void> undoDelete(NoteModel note) async {
    _pendingDeleteTimers.remove(note.id)?.cancel();
    await _local.restoreNote(note.id, DateTime.now());
  }

  Future<void> _pushIfAllowed(NoteModel note) async {
    if (!isLoggedIn) return;
    if (await _connectivity.isOnline) {
      try {
        await _remote.pushNote(note);
        await _local.markSynced(note.id);
      } catch (_) {
      }
    }
  }

  Future<void> syncNow() async {
    if (!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;

    final unsynced = await _local.getUnsyncedNotes();
    for (final note in unsynced) {
      try {
        if (note.isDeleted) {
          await _remote.deleteNote(note.id);
          await _local.deleteNote(note.id);
        } else {
          await _remote.pushNote(note);
          await _local.markSynced(note.id);
        }
      } catch (_) {
        continue;
      }
    }
    await _local.purgeSyncedDeletes();
    final remoteNotes = await _remote.fetchAllNotes();
    final toApply = await _resolveConflicts(remoteNotes);
    if (toApply.isNotEmpty) await _local.upsertMany(toApply);
  }

  void startRemoteListener(void Function() onChanged) {
    _remoteSub?.cancel();
    if (!isLoggedIn) return;
    _remoteSub = _remote.watchNotes().listen((remoteNotes) async {
      final toApply = await _resolveConflicts(remoteNotes);
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

  Future<List<NoteModel>> _resolveConflicts(List<NoteModel> remoteNotes) async {
    final localNotes = await _local.getAllNotesIncludingDeleted();
    final localById = {for (final n in localNotes) n.id: n};
    return [
      for (final r in remoteNotes)
        if (localById[r.id] == null ||
            r.updatedAt.isAfter(localById[r.id]!.updatedAt))
          r,
    ];
  }
}
