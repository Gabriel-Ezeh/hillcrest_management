import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final appDataBoxProvider = Provider<Box>((ref) {
  // This provider gives raw access to the Hive box.
  return Hive.box('appData');
});

// --- Onboarding State --- //
final hasSeenOnboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final box = ref.read(appDataBoxProvider);
    return box.get('hasSeenOnboarding', defaultValue: false);
  }

  void markAsSeen() {
    final box = ref.read(appDataBoxProvider);
    box.put('hasSeenOnboarding', true);
    state = true; // update provider state
  }
}

// --- Username Persistence --- //
final lastUsedUsernameProvider =
    NotifierProvider<LastUsedUsernameNotifier, String?>(
  LastUsedUsernameNotifier.new,
);

class LastUsedUsernameNotifier extends Notifier<String?> {
  static const _kUsernameKey = 'lastUsedUsername';

  @override
  String? build() {
    final box = ref.read(appDataBoxProvider);
    return box.get(_kUsernameKey);
  }

  Future<void> saveUsername(String username) async {
    final box = ref.read(appDataBoxProvider);
    await box.put(_kUsernameKey, username);
    state = username;
  }
}
