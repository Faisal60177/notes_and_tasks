import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:NoteFlow/core/constants/owner_ids.dart';
import 'auth_notifier.dart';

part 'current_owner_provider.g.dart';

@Riverpod(keepAlive: true)
String currentOwnerId(Ref ref) {
  return ref.watch(
    authProvider.select(
          (s) => s.isLoggedIn && s.uid.isNotEmpty ? s.uid : kGuestOwnerId,
    ),
  );
}