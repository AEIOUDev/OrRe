import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final vibrationStateProvider =
    StateNotifierProvider<HapticStateProvider, bool>((ref) {
  return HapticStateProvider();
});

class HapticStateProvider extends StateNotifier<bool> {
  HapticStateProvider() : super(true) {
    loadHapticState();
  }

  void toggleHapticState() {
    state = !state;
    saveHapticState();
  }

  Future<void> loadHapticState() async {
    // Load haptic state from local storage
    final prefs = await SharedPreferences.getInstance();
    final hapticState = prefs.getBool('hapticState') ?? true;
    state = hapticState;
  }

  Future<void> saveHapticState() async {
    // Save haptic state to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticState', state);
  }
}
