import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/notes/data/models/note_model.dart';
import '../providers/notes_notifier.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';


class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _openEditor(BuildContext context, {NoteModel? existingNote}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(existingNote: existingNote)),
    );
  }

  void _deleteWithUndo(BuildContext context, WidgetRef ref, NoteModel note) {
    ref.read(notesProvider.notifier).deleteNote(note);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => ref.read(notesProvider.notifier).restoreNote(note),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: (notesAsync.value?.isSyncing ?? false)
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            onPressed: () => ref.read(notesProvider.notifier).syncNow(),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (notesListState) {
          final notes = notesListState.notes;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet — tap + to add one!'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => _openEditor(context, existingNote: note),
                onTogglePin: () => ref.read(notesProvider.notifier).togglePinned(note),
                onDelete: () => _deleteWithUndo(context, ref, note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
