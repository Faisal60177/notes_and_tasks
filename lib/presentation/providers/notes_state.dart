import 'package:notes_app/features/notes/data/models/note_model.dart';

class NotesListState {
  final List<NoteModel> notes;
  final bool isSyncing;

  const NotesListState({this.notes = const [], this.isSyncing = false});

  NotesListState copyWith({List<NoteModel>? notes, bool? isSyncing}) {
    return NotesListState(
      notes: notes ?? this.notes,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}
