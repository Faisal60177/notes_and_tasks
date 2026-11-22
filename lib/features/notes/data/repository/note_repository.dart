import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:NoteFlow/core/services/connectivity_service.dart';
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

  Future<void> adoptGuestData() async {
    if (!isLoggedIn) return;
    await _local.adoptGuestRows();
  }

  Future<void> addNote({
    required String title,
    String? content,
    NoteColor color = NoteColor.default_,
    String? category,
    bool isPinned = false,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      color: color,
      category: category,
      isPinned: isPinned,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    await _local.upsertNote(note);
    unawaited(_push(note));
  }

  Future<void> updateNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: DateTime.now(), isSynced: false);
    await _local.upsertNote(updated);
    unawaited(_push(updated));
  }

  Future<void> togglePinned(NoteModel note) =>
      updateNote(note.copyWith(isPinned: !note.isPinned));

  Future<void> deleteNote(
      NoteModel note, {
        Duration undoWindow = const Duration(seconds: 5),
      }) async {
    final deletedAt = DateTime.now();
    await _local.softDeleteNote(note.id, deletedAt);

    final tombstone =
    note.copyWith(isDeleted: true, updatedAt: deletedAt, isSynced: false);

    _pendingDeleteTimers[note.id]?.cancel();
    _pendingDeleteTimers[note.id] = Timer(undoWindow, () {
      _pendingDeleteTimers.remove(note.id);
      _finalizeDelete(tombstone);
    });
  }

  Future<void> _finalizeDelete(NoteModel tombstone) async {
    if (!isLoggedIn) {
      await _local.deleteNote(tombstone.id);
      return;
    }
    if (await _push(tombstone)) {
      await _local.purgeSyncedDeletes();
    }
  }

  Future<void> undoDelete(NoteModel note) async {
    _pendingDeleteTimers.remove(note.id)?.cancel();
    final now = DateTime.now();
    await _local.restoreNote(note.id, now);
    unawaited(
      _push(note.copyWith(isDeleted: false, isSynced: false, updatedAt: now)),
    );
  }

  Future<bool> _push(NoteModel note) async {
    if (!isLoggedIn) return false;
    if (!await _connectivity.isOnline) return false;
    return _pushOne(note);
  }

  Future<bool> _pushOne(NoteModel note) async {
    try {
      await _remote.pushNote(note);
      await _local.markSynced(note.id, note.updatedAt);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncNow() async {
    if (!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;

    final unsynced = await _local.getUnsyncedNotes();
    for (final note in unsynced) {
      await _pushOne(note);
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
        if (_shouldApply(r, localById[r.id])) r,
    ];
  }

  bool _shouldApply(NoteModel remote, NoteModel? local) {
    if (local == null) return !remote.isDeleted;
    return remote.updatedAt.isAfter(local.updatedAt);
  }
}