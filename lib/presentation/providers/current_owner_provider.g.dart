// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_owner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentOwnerId)
final currentOwnerIdProvider = CurrentOwnerIdProvider._();

final class CurrentOwnerIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  CurrentOwnerIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOwnerIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOwnerIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currentOwnerId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentOwnerIdHash() => r'4d27f944b3c47946edd2fbf2fe91e213599b4681';
