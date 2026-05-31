import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

class NoteController extends GetxController{

  final DbHelper _dbHelper = DbHelper();

// RxList — Rx means Reactive, that mean if the list change the UI also update automatically
// .obs means observable — GetX will do watch this
RxList<NoteModel> notes= <NoteModel>[].obs;

// To keep the search  notes in separate list
RxList<NoteModel> filteredNotes = <NoteModel>[].obs;

RxBool isSearching = false.obs;
RxBool isLoading = false.obs;

@override
  void onInit(){
  super.onInit();
  loadNotes(); // when app will open then show all notes
}

Future<void> loadNotes() async{
  isLoading.value = true;
  notes.value = await _dbHelper.getAllNotes();
  isLoading.value = false; // loading is finished
}

Future<void> addNote({
    required String title,
  required String content,
  required int color,
}) async {
  String now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  NoteModel newNote = NoteModel(title: title, content: content, color: color, createdAt: now, updatedAt: now);

  await _dbHelper.insertNote(newNote);
  await loadNotes(); // do list refresh — UI will update autometically

  Get.snackbar(
    'Success!', 'Notes saved',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition:  SnackPosition.BOTTOM,
  );
}






}