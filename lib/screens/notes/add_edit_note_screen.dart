import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../widgets/color_picker_widget.dart';

// AddEditNoteScreen — Note যোগ ও সম্পাদনা উভয় কাজ এই screen করে
// যদি existingNote null হয় → নতুন note যোগ
// যদি existingNote দেওয়া থাকে → সেটা edit
class AddEditNoteScreen extends StatefulWidget {

  // null হলে নতুন note, নইলে edit mode
  final NoteModel? existingNote;

  const AddEditNoteScreen({super.key, this.existingNote});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {

  // TextEditingController — TextField এর text পড়ার ও সেট করার জন্য
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Form validation এর জন্য GlobalKey দরকার
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // GetX controller find করো — আগে যেটা put করা ছিল সেটাই আসবে
  final NoteController _noteController = Get.find<NoteController>();

  // বেছে নেওয়া color — শুরুতে সাদা
  int _selectedColor = ColorPickerWidget.noteColors[0].value;

  @override
  void initState() {
    super.initState();
    // initState — widget তৈরি হওয়ার সাথে সাথে চলে

    // Edit mode হলে পুরনো তথ্য দিয়ে field ভরো
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
    }
  }

  @override
  void dispose() {
    // dispose — widget ধ্বংস হওয়ার সময় controller dispose করো
    // না করলে memory leak হবে
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Save button চাপলে এই function চলবে
  Future<void> _saveNote() async {
    // Form validate করো — সব field ঠিকঠাক কিনা দেখো
    if (!_formKey.currentState!.validate()) return;

    if (widget.existingNote == null) {
      // নতুন note যোগ করো
      await _noteController.addNote(
        title: _titleController.text.trim(), // trim() — আগে পরে space সরাও
        content: _contentController.text.trim(),
        color: _selectedColor,
      );
    } else {
      // আগের note আপডেট করো
      await _noteController.updateNote(
        note: widget.existingNote!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        color: _selectedColor,
      );
    }

    Get.back(); // আগের screen এ ফিরে যাও
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingNote != null; // edit mode কিনা

    return Scaffold(
      backgroundColor: Color(_selectedColor), // card color অনুযায়ী background
      appBar: AppBar(
        backgroundColor: Color(_selectedColor),
        elevation: 0,
        title: Text(isEditing ? 'Note সম্পাদনা' : 'নতুন Note'),
        actions: [
          // Save button AppBar এ
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveNote,
            tooltip: 'সংরক্ষণ করুন',
          ),
        ],
      ),

      body: Form(
        key: _formKey, // Form এর key দাও validation এর জন্য
        child: SingleChildScrollView(
          // SingleChildScrollView — keyboard আসলে scroll করা যাবে
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Color picker
              const Text('রঙ বেছে নিন:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ColorPickerWidget(
                selectedColor: _selectedColor,
                onColorSelected: (colorValue) {
                  // setState — color বদলালে UI rebuild করো
                  setState(() {
                    _selectedColor = colorValue;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'শিরোনাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  // validator — field empty হলে error message দেখাও
                  if (value == null || value.trim().isEmpty) {
                    return 'শিরোনাম দিন';
                  }
                  return null; // null মানে কোনো error নেই
                },
              ),

              const SizedBox(height: 16),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'লিখুন...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // label উপরে থাকবে
                ),
                maxLines: 15, // বড় text area
                minLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'কিছু লিখুন';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save button নিচে
              SizedBox(
                width: double.infinity, // পুরো প্রস্থ নাও
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}