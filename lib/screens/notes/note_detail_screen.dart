import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart';
import '../../controllers/note_controller.dart';
import 'add_edit_note_screen.dart';

// Note এর সম্পূর্ণ বিবরণ দেখানোর screen
class NoteDetailScreen extends StatelessWidget {

  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {

    final NoteController controller = Get.find<NoteController>();
    Color cardColor = Color(note.color);
    Color textColor = cardColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Edit button
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () {
              // Edit screen এ যাও — ফিরে এলে updated note দেখাবে
              Get.off(() => AddEditNoteScreen(existingNote: note));
            },
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete, color: textColor),
            onPressed: () {
              // Delete confirm করো
              Get.defaultDialog(
                title: 'মুছে ফেলবেন?',
                middleText: '"${note.title}" মুছে যাবে।',
                textConfirm: 'হ্যাঁ',
                textCancel: 'না',
                onConfirm: () {
                  controller.deleteNote(note);
                  Get.back(); // dialog বন্ধ
                  Get.back(); // detail screen থেকে বেরিয়ে যাও
                },
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title
            Text(
              note.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 8),

            // তারিখ
            Text(
              'আপডেট: ${note.updatedAt}',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
            ),

            const Divider(height: 24),

            // সম্পূর্ণ content
            Text(
              note.content,
              style: TextStyle(fontSize: 16, color: textColor, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}