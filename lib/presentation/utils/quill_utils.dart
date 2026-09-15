import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

Document documentFromContent(String? content) {
  if (content == null || content.isEmpty) return Document();
  try {
    return Document.fromJson(jsonDecode(content));
  } catch (_) {
    return Document()..insert(0, content);
  }
}

String contentToJsonString(Document doc) => jsonEncode(doc.toDelta().toJson());

String contentToPlainPreview(String? content) {
  if (content == null || content.isEmpty) return '';
  final doc = documentFromContent(content);
  return doc.toPlainText().trim();
}