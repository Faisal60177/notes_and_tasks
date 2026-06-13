import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

class NoteController extends GetxController {
  final DbHelper _dbHelper = DbHelper();

  // Reactive list — UI auto updates when this changes
  RxList<NoteModel> notes = <NoteModel>[].obs;
  RxList<NoteModel> filteredNotes = <NoteModel>[].obs;
  RxBool isSearching = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  // Load all notes from database
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      notes.value = await _dbHelper.getAllNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notes: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // finally — always runs, even if error occurs
      // this ensures isLoading becomes false no matter what
      isLoading.value = false;
    }
  }

  // Add new note
  Future<void> addNote({
    required String title,
    required String content,
    required int color,
  }) async {
    try {
      String now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
      NoteModel newNote = NoteModel(
        title: title,
        content: content,
        color: color,
        createdAt: now,
        updatedAt: now,
      );
      await _dbHelper.insertNote(newNote);
      await loadNotes();
      Get.snackbar(
        'Success', 'Note saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save note: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update existing note
  Future<void> updateNote({
    required NoteModel note,
    required String title,
    required String content,
    required int color,
  }) async {
    try {
      String now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
      NoteModel updatedNote = NoteModel(
        id: note.id,
        title: title,
        content: content,
        color: color,
        createdAt: note.createdAt,
        updatedAt: now,
      );
      await _dbHelper.updateNote(updatedNote);
      await loadNotes();
      Get.snackbar(
        'Success', 'Note updated successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete note with undo option
  Future<void> deleteNote(NoteModel note) async {
    try {
      await _dbHelper.deleteNote(note.id!);
      await loadNotes();
      Get.snackbar(
        'Deleted', '"${note.title}" deleted',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () async {
            await _dbHelper.insertNote(NoteModel(
              title: note.title,
              content: note.content,
              color: note.color,
              createdAt: note.createdAt,
              updatedAt: note.updatedAt,
            ));
            await loadNotes();
          },
          child: const Text('Undo', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Search notes by keyword
  Future<void> searchNotes(String keyword) async {
    if (keyword.isEmpty) {
      isSearching.value = false;
      filteredNotes.clear();
      return;
    }
    isSearching.value = true;
    filteredNotes.value = await _dbHelper.searchNotes(keyword);
  }

  // Clear search
  void clearSearch() {
    isSearching.value = false;
    filteredNotes.clear();
  }
}