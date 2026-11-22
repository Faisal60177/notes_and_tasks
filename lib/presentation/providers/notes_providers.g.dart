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
    r'dfc408912994a8b7eb751169d74ef2738a64c9c0';

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
    r'4735222723c7663d41e7a722235a2be050e1316a';

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

String _$noteRepositoryHash() => r'9fd4fa8b6c3263aa733ee3c7c0f5c0a828795050';
