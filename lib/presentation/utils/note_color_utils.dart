import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/data/models/note_model.dart';

Color noteColorToColor(NoteColor color, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  switch (color) {
    case NoteColor.default_:
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    case NoteColor.red:
      return isDark ? Colors.red.shade900.withOpacity(0.35) : Colors.red.shade100;
    case NoteColor.orange:
      return isDark ? Colors.orange.shade900.withOpacity(0.35) : Colors.orange.shade100;
    case NoteColor.yellow:
      return isDark ? Colors.yellow.shade900.withOpacity(0.35) : Colors.yellow.shade100;
    case NoteColor.green:
      return isDark ? Colors.green.shade900.withOpacity(0.35) : Colors.green.shade100;
    case NoteColor.blue:
      return isDark ? Colors.blue.shade900.withOpacity(0.35) : Colors.blue.shade100;
    case NoteColor.purple:
      return isDark ? Colors.purple.shade900.withOpacity(0.35) : Colors.purple.shade100;
    case NoteColor.pink:
      return isDark ? Colors.pink.shade900.withOpacity(0.35) : Colors.pink.shade100;
  }
}