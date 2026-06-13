import 'package:flutter/material.dart';

// ColorPickerWidget — Note color selection widget
class ColorPickerWidget extends StatelessWidget {

  // can select colors form this colors
  static const List<Color> noteColors = [
    Color(0xFFFFFFFF),
    Color(0xFFFFD3B6),
    Color(0xFFFFAFCC),
    Color(0xFFBDE0FE),
    Color(0xFFA8DADC),
    Color(0xFFCBB3F0),
    Color(0xFFB7E4C7),
    Color(0xFFFFF3B0),
  ];

  // Now which color selected
  final int selectedColor;
  // color change then inform parent
  final Function(int) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      // In Row many color then can scroll
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // cross scroll
        itemCount: noteColors.length,
        itemBuilder: (context, index) {
          Color color = noteColors[index];
          // does this color selected now
          bool isSelected = color.value == selectedColor;

          return GestureDetector(
            onTap: () => onColorSelected(color.value), // color int value send
            child: AnimatedContainer(
              // AnimatedContainer — size change then smooth animation
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 44 : 36, // selected then large
              height: isSelected ? 44 : 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  // if selected then thick border, if not then thin
                  color: isSelected ? Colors.black54 : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
              ),
              // if selected then show checkmark
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.black54)
                  : null,
            ),
          );
        },
      ),
    );
  }
}