// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoNotifier)
final todoProvider = TodoNotifierProvider._();

final class TodoNotifierProvider
    extends $AsyncNotifierProvider<TodoNotifier, TodoListState> {
  TodoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoNotifierHash();

  @$internal
  @override
  TodoNotifier create() => TodoNotifier();
}

String _$todoNotifierHash() => r'5b9e24333a7dea829b1f0fc176aafa876295f6e2';

abstract class _$TodoNotifier extends $AsyncNotifier<TodoListState> {
  FutureOr<TodoListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodoListState>, TodoListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodoListState>, TodoListState>,
              AsyncValue<TodoListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
