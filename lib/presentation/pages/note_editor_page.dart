import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../utils/note_color_utils.dart';
import 'package:NoteFlow/features/notes/data/models/note_model.dart';
import '../providers/notes_notifier.dart';
import '../utils/quill_utils.dart';
import '../widgets/note_toolbar.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final NoteModel? existingNote;
  const NoteEditorPage({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final QuillController _quillController;
  late final DateTime _referenceDate;
  late NoteColor _color;
  late bool _isPinned;

  late final FocusNode _editorFocusNode;
  late final ScrollController _editorScrollController;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _categoryCtrl = TextEditingController(text: note?.category ?? '');
    _quillController = QuillController(
      document: documentFromContent(note?.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.addListener(_onDocChanged);
    _referenceDate = note?.updatedAt ?? DateTime.now();
    _color = note?.color ?? NoteColor.default_;
    _isPinned = note?.isPinned ?? false;
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();
  }

  void _onDocChanged() => setState(() {});

  int get _wordCount {
    final text = _quillController.document.toPlainText().trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _quillController.removeListener(_onDocChanged);
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final notifier = ref.read(notesProvider.notifier);
    final category = _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim();
    final content = contentToJsonString(_quillController.document);

    if (_isEditing) {
      notifier.updateNote(widget.existingNote!.copyWith(
        title: _titleCtrl.text.trim(),
        content: content,
        color: _color,
        category: category,
        clearCategory: category == null,
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
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none, isDense:  true,
                  contentPadding: .zero),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              '${DateFormat('MMMM d, h:mm a, EEE').format(_referenceDate)}  |  $_wordCount words',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 16, 0),
            child: TextField(
              controller: _categoryCtrl,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.label_outline, size: 12),
                prefixIconConstraints: BoxConstraints(minWidth: 28, minHeight: 20),
                hintText: 'Add category',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          const SizedBox(height: 06,),
          Expanded(
            child: QuillEditor(
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              controller: _quillController,
              config: const QuillEditorConfig(
                placeholder: 'Start writing your note...',
                padding: EdgeInsets.all(12),
                expands: true,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: NoteToolbar(controller: _quillController),
            ),
          ),
        ],
      ),
    );
  }
}