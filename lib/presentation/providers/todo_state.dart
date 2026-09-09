import 'package:notes_app/features/todo/data/models/todo_model.dart';

class TodoListState {
  final List<TodoModel> todos;
  final bool isSyncing;

  const TodoListState({this.todos = const [], this.isSyncing = false});

  TodoListState copyWith({List<TodoModel>? todos, bool? isSyncing}) {
    return TodoListState(
      todos:  todos ?? this.todos,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}