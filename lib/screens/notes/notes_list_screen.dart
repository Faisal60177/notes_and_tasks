import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../widgets/note_card.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatelessWidget {

  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Get.find — আগে put করা controller খুঁজে নাও
    final NoteController controller = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My  Notes'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),

      // Obx — GetX এর reactive widget
      // controller এর obs variable বদলালে শুধু এই অংশটা rebuild হয়
      // পুরো page rebuild হয় না — এটাই GetX এর সুবিধা
      body: Obx(() {

        // Loading এর সময় spinner দেখাও
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // কোন list দেখাবে — search list নাকি সব notes
        List notes = controller.isSearching.value
            ? controller.filteredNotes
            : controller.notes;

        // Notes নেই তাহলে empty state দেখাও
        if (notes.isEmpty) {
          return EmptyState(
            icon: controller.isSearching.value
                ? Icons.search_off
                : Icons.note_add,
            message: controller.isSearching.value
                ? 'No notes found'
                : 'No notes yet\nTap + to add a new note',
          );
        }

        return ListView.builder(
          // ListView.builder — শুধু দৃশ্যমান item render করে
          // সব item একসাথে render করে না — performance ভালো
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: notes[index],
              onTap: () {
                // Detail screen এ যাও, note এর তথ্য পাঠাও
                Get.to(() => NoteDetailScreen(note: notes[index]));
              },
              onEdit: () {
                // Edit screen এ যাও
                Get.to(() => AddEditNoteScreen(existingNote: notes[index]));
              },
              onDelete: () => controller.deleteNote(notes[index]),
            );
          },
        );
      }),

      // FAB — নতুন note যোগ করার button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditNoteScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Search dialog দেখাও
  void _showSearchDialog(BuildContext context, NoteController controller) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Notes'),
        content: TextField(
          controller: searchController,
          autofocus: true, // dialog খুলতেই keyboard আসবে
          decoration: const InputDecoration(
            hintText: 'Search by title or content...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.searchNotes(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSearch();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}