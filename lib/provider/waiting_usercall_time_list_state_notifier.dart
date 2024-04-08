import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingUserCallTimeListStateNotifier extends StateNotifier<Duration> {
  DateTime? userCallTime;
  Timer? timer;
  WaitingUserCallTimeListStateNotifier() : super(Duration.zero);

  void setUserCallTime(DateTime userCallTime) {
    this.userCallTime = userCallTime;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateDifference(userCallTime);
    });
  }

  void updateDifference(DateTime userCallTime) {
    final currentTime = DateTime.now();
    final difference = userCallTime.difference(currentTime);
    print(difference);

    if (difference.inSeconds < 0) {
      deleteTimer();
    } else {
      state = difference;
    }
  }

  void deleteTimer() {
    timer?.cancel();
    state = Duration.zero;
    return;
  }
}

final waitingUserCallTimeListProvider =
    StateNotifierProvider<WaitingUserCallTimeListStateNotifier, Duration>(
  (ref) => WaitingUserCallTimeListStateNotifier(),
);
