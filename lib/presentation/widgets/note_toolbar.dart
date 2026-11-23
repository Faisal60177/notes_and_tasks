import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

enum _ToolCategory { text, list, insert, history }

class NoteToolbar extends StatefulWidget {
  final QuillController controller;
  const NoteToolbar({super.key, required this.controller});

  @override
  State<NoteToolbar> createState() => _NoteToolbarState();
}

class _NoteToolbarState extends State<NoteToolbar> {
  _ToolCategory _selected = _ToolCategory.text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(children: _buildToolsForCategory()),
          ),
        ),
        SizedBox(
          height: 52,
          child: Row(
            children: _ToolCategory.values.map((cat) {
              final isSelected = cat == _selected;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selected = cat),
                  child: Container(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                        : Colors.transparent,
                    child: Icon(
                      _iconFor(cat),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(_ToolCategory cat) {
    switch (cat) {
      case _ToolCategory.text:
        return Icons.format_size;
      case _ToolCategory.list:
        return Icons.format_list_bulleted;
      case _ToolCategory.insert:
        return Icons.add_box_outlined;
      case _ToolCategory.history:
        return Icons.history;
    }
  }

  List<Widget> _buildToolsForCategory() {
    final c = widget.controller;
    switch (_selected) {
      case _ToolCategory.text:
        return [
          QuillToolbarSelectHeaderStyleDropdownButton(controller: c),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.bold),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.italic),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.underline),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.strikeThrough),
          QuillToolbarColorButton(controller: c, isBackground: false),
          QuillToolbarColorButton(controller: c, isBackground: true),
          QuillToolbarClearFormatButton(controller: c),
          QuillToolbarFontFamilyButton(controller: c),
          QuillToolbarFontSizeButton(controller: c),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.inlineCode),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.superscript),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.subscript),
          QuillToolbarSelectAlignmentButton(controller: c),
        ];
      case _ToolCategory.list:
        return [
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.ol),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.ul),
          QuillToolbarToggleCheckListButton(controller: c),
          QuillToolbarIndentButton(controller: c, isIncrease: true),
          QuillToolbarIndentButton(controller: c, isIncrease: false),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.blockQuote),
          QuillToolbarToggleStyleButton(controller: c, attribute: Attribute.codeBlock),
        ];
      case _ToolCategory.insert:
        return [
          QuillToolbarLinkStyleButton(controller: c),
          QuillToolbarClearFormatButton(controller: c),
          QuillToolbarClipboardButton(controller: c, clipboardAction: ClipboardAction.cut),
          QuillToolbarClipboardButton(controller: c, clipboardAction: ClipboardAction.copy),
          QuillToolbarClipboardButton(controller: c, clipboardAction: ClipboardAction.paste),
          QuillToolbarSearchButton(controller: c),
        ];
      case _ToolCategory.history:
        return [
          QuillToolbarHistoryButton(controller: c, isUndo: true),
          QuillToolbarHistoryButton(controller: c, isUndo: false),
        ];
    }
  }
}