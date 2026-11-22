// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NoteViewIsGrid)
final noteViewIsGridProvider = NoteViewIsGridProvider._();

final class NoteViewIsGridProvider
    extends $NotifierProvider<NoteViewIsGrid, bool> {
  NoteViewIsGridProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteViewIsGridProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteViewIsGridHash();

  @$internal
  @override
  NoteViewIsGrid create() => NoteViewIsGrid();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$noteViewIsGridHash() => r'cd8958003e57ed44df2db872ee33225827aa6a11';

abstract class _$NoteViewIsGrid extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
