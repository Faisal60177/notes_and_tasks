import 'package:equatable/equatable.dart';
import 'package:notes_app/features/todo/data/models/todo_model.dart';

enum TodoStatus {initial, loading, loaded, error}

class TodoState  extends Equatable{
  final TodoStatus status;
  final List<TodoModel> todos;
  final  bool isSyncing;
  final String? errorMessage;

  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const[],
    this.isSyncing = false,
    this.errorMessage,
});

  TodoState copyWith({
    TodoStatus? status,
    List<TodoModel>? todos,
    bool? isSyncing,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, todos, isSyncing, errorMessage];


}