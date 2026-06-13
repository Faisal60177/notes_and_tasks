import 'package:flutter/cupertino.dart';
import '../models/note_model.dart';
import 'package:flutter/material.dart';



class NoteCard extends StatelessWidget{

  final NoteModel note;          // which note
  final VoidCallback onTap;      // card  tap then what will do
  final VoidCallback onDelete;   // delete icon
  final VoidCallback onEdit;     // edit icon

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });


  @override
  Widget build(BuildContext context) {
    Color cardColor = Color(note.color);

    // cardColor if too much dark then the text will white, otherwise Black
    // computeLuminance() — color bright will  0.0 to  1.0.

    Color textColor = cardColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // left side align
            children: [

              // Title and action buttons in one row
              Row(
                children: [
                  Expanded(
                    // Expanded — keep all other places
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,          // remove if many
                      overflow: TextOverflow.ellipsis, // ... will end
                    ),
                  ),

                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textColor, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero, // extra padding remove
                    constraints: const BoxConstraints(), // minimum size remove
                  ),

                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: textColor, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Note content preview
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.85),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // date will show below with little
              Text(
                note.updatedAt,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),


      ),

    );



  }}