import 'dart:async';
import 'package:riverpod/riverpod.dart';

final timerProvider = StateNotifierProvider<TimerStateNotifier, int>((ref) {
  return TimerStateNotifier();
});

class TimerStateNotifier extends StateNotifier<int> {
  Timer? _timer;

  TimerStateNotifier() : super(0);

  void startTimer() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (state > 0) {
        state = state - 1;
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void resetTimer() {
    state = 0;
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void setTimer(int seconds) {
    state = seconds;
  }

  void setAndStartTimer(int seconds) {
    setTimer(seconds);
    startTimer();
  }

  void cancelTimer() {
    stopTimer();
    resetTimer();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}
