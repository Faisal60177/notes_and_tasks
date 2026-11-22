import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_helper.dart';
import '../services/connectivity_service.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper.instance;
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService();
}

@Riverpod(keepAlive: true)
Stream<bool> connectivityStatus(Ref ref) {
  return ref.watch(connectivityServiceProvider).onStatusChange;
}