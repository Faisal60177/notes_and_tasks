import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_view_provider.g.dart';

@Riverpod(keepAlive: true)
class NoteViewIsGrid extends _$NoteViewIsGrid {
  @override
  bool build() => true;

  void toggle() => state = !state;
}