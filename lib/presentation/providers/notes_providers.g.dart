// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noteLocalDatasource)
final noteLocalDatasourceProvider = NoteLocalDatasourceProvider._();

final class NoteLocalDatasourceProvider
    extends
        $FunctionalProvider<
          NoteLocalDatasource,
          NoteLocalDatasource,
          NoteLocalDatasource
        >
    with $Provider<NoteLocalDatasource> {
  NoteLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<NoteLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NoteLocalDatasource create(Ref ref) {
    return noteLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteLocalDatasource>(value),
    );
  }
}

String _$noteLocalDatasourceHash() =>
    r'a5c6803802c6383c82f1f57c8226f23d226f44be';

@ProviderFor(noteRemoteDatasource)
final noteRemoteDatasourceProvider = NoteRemoteDatasourceProvider._();

final class NoteRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          NoteRemoteDatasource,
          NoteRemoteDatasource,
          NoteRemoteDatasource
        >
    with $Provider<NoteRemoteDatasource> {
  NoteRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRemoteDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<NoteRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NoteRemoteDatasource create(Ref ref) {
    return noteRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRemoteDatasource>(value),
    );
  }
}

String _$noteRemoteDatasourceHash() =>
    r'f21688210701e58f43704c41a3dec9813b6fe83e';

@ProviderFor(noteRepository)
final noteRepositoryProvider = NoteRepositoryProvider._();

final class NoteRepositoryProvider
    extends $FunctionalProvider<NoteRepository, NoteRepository, NoteRepository>
    with $Provider<NoteRepository> {
  NoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteRepository create(Ref ref) {
    return noteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRepository>(value),
    );
  }
}

String _$noteRepositoryHash() => r'7a3bbbeb2a5a453dfcca18ef4891c493591e0a27';
