import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:NoteFlow/features/notes/data/models/note_model.dart';
import '../providers/notes_notifier.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

final noteViewIsGridProvider = StateProvider<bool>((ref) => true);

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _openEditor(BuildContext context, {NoteModel? existingNote}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // ⚠️ hideCurrentSnackBar থেকে বদলানো
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(existingNote: existingNote)),
    );
  }

  void _deleteWithUndo(BuildContext context, WidgetRef ref, NoteModel note) {
    ref.read(notesProvider.notifier).deleteNote(note);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => ref.read(notesProvider.notifier).undoDelete(note),
        ),
      ),
    );

    // ⚠️ নতুন — framework-এর নিজস্ব auto-dismiss timer stuck হয়ে গেলেও,
    // এটা নিশ্চিতভাবে ৪ সেকেন্ড পর snackbar জোর করে সরিয়ে দেবে।
    Future.delayed(const Duration(seconds: 4), () {
      messenger.removeCurrentSnackBar();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final isGrid = ref.watch(noteViewIsGridProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            tooltip: isGrid ? 'List view' : 'Grid view',
            onPressed: () => ref.read(noteViewIsGridProvider.notifier).state = !isGrid,
          ),
          IconButton(
            icon: (notesAsync.value?.isSyncing ?? false)
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
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
          return isGrid ? _buildGrid(context, ref, notes) : _buildList(context, ref, notes);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notesFab',
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<NoteModel> notes) {
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
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<NoteModel> notes) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
  }
}