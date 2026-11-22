// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoLocalDatasource)
final todoLocalDatasourceProvider = TodoLocalDatasourceProvider._();

final class TodoLocalDatasourceProvider
    extends
        $FunctionalProvider<
          TodoLocalDatasource,
          TodoLocalDatasource,
          TodoLocalDatasource
        >
    with $Provider<TodoLocalDatasource> {
  TodoLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<TodoLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoLocalDatasource create(Ref ref) {
    return todoLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoLocalDatasource>(value),
    );
  }
}

String _$todoLocalDatasourceHash() =>
    r'ead4ede296797552a3a14369772f3d20fd75d0ab';

@ProviderFor(todoRemoteDatasource)
final todoRemoteDatasourceProvider = TodoRemoteDatasourceProvider._();

final class TodoRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          TodoRemoteDatasource,
          TodoRemoteDatasource,
          TodoRemoteDatasource
        >
    with $Provider<TodoRemoteDatasource> {
  TodoRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoRemoteDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<TodoRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoRemoteDatasource create(Ref ref) {
    return todoRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoRemoteDatasource>(value),
    );
  }
}

String _$todoRemoteDatasourceHash() =>
    r'802820d5376df1e01b4bec31d1d2b6ceacbf96b8';

@ProviderFor(todoRepository)
final todoRepositoryProvider = TodoRepositoryProvider._();

final class TodoRepositoryProvider
    extends $FunctionalProvider<TodoRepository, TodoRepository, TodoRepository>
    with $Provider<TodoRepository> {
  TodoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodoRepository create(Ref ref) {
    return todoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoRepository>(value),
    );
  }
}

String _$todoRepositoryHash() => r'9237599087b01748c65e012cb33f52d2b6866f7d';
