import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hillcrest_finance/app/core/storage/user_local_storage.dart';

/// A provider that creates and exposes the [UserLocalStorage] service.
final userLocalStorageProvider = Provider<UserLocalStorage>((ref) {
  // Get the Hive box that was opened in main.dart
  final box = Hive.box('appData');
  return UserLocalStorage(box);
});
