import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes_app/features/notes/data/models/note_model.dart';
import '../providers/notes_notifier.dart';
import '../widgets/note_card.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final NoteModel? existingNote;
  const NoteEditorPage({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _categoryCtrl;
  late NoteColor _color;
  late bool _isPinned;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _contentCtrl = TextEditingController(text: note?.content ?? '');
    _categoryCtrl = TextEditingController(text: note?.category ?? '');
    _color = note?.color ?? NoteColor.default_;
    _isPinned = note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;

    final notifier = ref.read(notesProvider.notifier);
    final category = _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim();
    final content = _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim();

    if (_isEditing) {
      notifier.updateNote(widget.existingNote!.copyWith(
        title: _titleCtrl.text.trim(),
        content: content,
        color: _color,
        category: category,
        isPinned: _isPinned,
      ));
    } else {
      notifier.addNote(
        title: _titleCtrl.text.trim(),
        content: content,
        color: _color,
        category: category,
      );
    }
    Navigator.pop(context);
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: NoteColor.values.map((c) {
              final isSelected = c == _color;
              return GestureDetector(
                onTap: () {
                  setState(() => _color = c);
                  Navigator.pop(sheetCtx);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: noteColorToColor(c, context),
                  child: isSelected ? const Icon(Icons.check, size: 18) : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noteColorToColor(_color, context),
      appBar: AppBar(
        backgroundColor: noteColorToColor(_color, context),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(icon: const Icon(Icons.palette_outlined), onPressed: _pickColor),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Category (optional) — e.g. Work, Personal',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            TextField(
              controller: _contentCtrl,
              maxLines: null,
              minLines: 10,
              decoration: const InputDecoration(
                hintText: 'Note',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}