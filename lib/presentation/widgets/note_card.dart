import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/data/models/note_model.dart';

Color noteColorToColor(NoteColor color, BuildContext context) {
  switch (color) {
    case NoteColor.default_:
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    case NoteColor.red:
      return Colors.red.shade100;
    case NoteColor.orange:
      return Colors.orange.shade100;
    case NoteColor.yellow:
      return Colors.yellow.shade100;
    case NoteColor.green:
      return Colors.green.shade100;
    case NoteColor.blue:
      return Colors.blue.shade100;
    case NoteColor.purple:
      return Colors.purple.shade100;
    case NoteColor.pink:
      return Colors.pink.shade100;
  }
}

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: noteColorToColor(note.color, context),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showQuickActions(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 14, color: Colors.grey.shade700),
                ],
              ),
              if (note.content != null && note.content!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ],
              if (note.category != null && note.category!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(note.category!, style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ],
              if (!note.isSynced) ...[
                const SizedBox(height: 4),
                const Icon(Icons.cloud_off, size: 12, color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(sheetCtx);
                onTogglePin();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(sheetCtx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

