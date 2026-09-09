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

  Future<void> deleteNote(NoteModel note) async {
    final now = DateTime.now();
    await _local.softDeleteNote(note.id, now);
    unawaited(_pushIfAllowed(note.copyWith(isDeleted: true, updatedAt: now)));
  }

  Future<void> restoreNote(NoteModel note) async {
    final now = DateTime.now();
    await _local.restoreNote(note.id, now);
    unawaited(_pushIfAllowed(note.copyWith(isDeleted: false, updatedAt: now)));
  }

  Future<void> _pushIfAllowed(NoteModel note) async {
    if (!isLoggedIn) return;
    if (await _connectivity.isOnline) {
      await _remote.pushNote(note);
      await _local.markSynced(note.id);
    }
  }

  Future<void> syncNow() async {
    if (!isLoggedIn) return;
    if (!await _connectivity.isOnline) return;

    final unsynced = await _local.getUnsyncedNotes();
    for (final note in unsynced) {
      await _remote.pushNote(note);
      await _local.markSynced(note.id);
    }
    await _local.purgeSyncedDeletes();

    final remoteNotes = await _remote.fetchAllNotes();
    final localNotes = await _local.getAllNotes();
    final localById = {for (final n in localNotes) n.id: n};

    final toApply = <NoteModel>[];
    for (final remoteNote in remoteNotes) {
      final localNote = localById[remoteNote.id];
      if (localNote == null || remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
        toApply.add(remoteNote);
      }
    }
    if (toApply.isNotEmpty) await _local.upsertMany(toApply);
  }

  void startRemoteListener(void Function() onChanged) {
    _remoteSub?.cancel();
    if (!isLoggedIn) return;
    _remoteSub = _remote.watchNotes().listen((remoteNotes) async {
      final localNotes = await _local.getAllNotes();
      final localById = {for (final n in localNotes) n.id: n};
      final toApply = <NoteModel>[];
      for (final remoteNote in remoteNotes) {
        final localNote = localById[remoteNote.id];
        if (localNote == null || remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
          toApply.add(remoteNote);
        }
      }
      if (toApply.isNotEmpty) {
        await _local.upsertMany(toApply);
        onChanged();
      }
    });
  }

  void dispose() => _remoteSub?.cancel();
}
