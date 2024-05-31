import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/debug.services.dart';

class WaitingUserCallTimeListStateNotifier extends StateNotifier<Duration?> {
  DateTime? userCallTime;
  Timer? timer;
  late Ref ref;

  WaitingUserCallTimeListStateNotifier(this.ref) : super(null);

  // Sets the user call time and starts a timer to update the remaining time
  void setUserCallTime(DateTime userCallTime) {
    if (userCallTime
        .toUtc()
        .isBefore(DateTime.now().toUtc().add(const Duration(hours: 9)))) {
      printd("유저 호출 시간이 현재 시간보다 이전입니다.");
      deleteTimer();
      return;
    } else {
      printd("유저 호출 시간이 현재 시간보다 이후입니다.");
    }
    this.userCallTime = userCallTime;
    startTimer();
  }

  // Starts a periodic timer that updates the time difference
  void startTimer() {
    // Cancel any existing timer before starting a new one
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      updateDifference();
    });
  }

  // Updates the remaining time and cancels the timer if the time is up
  void updateDifference() {
    if (userCallTime == null) {
      deleteTimer();
      return;
    }
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));

    // Convert userCallTime to local time
    final localUserCallTime = userCallTime!.toUtc();

    printd("유저 호출 시간 (로컬): $localUserCallTime");
    printd("현재 시간: $currentTime");

    if (currentTime.isAfter(localUserCallTime)) {
      printd("유저 호출 시간이 지났습니다.");
      deleteTimer();
      return;
    } else {
      printd("유저 호출 시간이 지나지 않았습니다.");
      printd(
          "유저 호출 시간까지 남은 시간: ${localUserCallTime.difference(currentTime).inSeconds}");
      state = localUserCallTime.difference(currentTime);
    }
  }

  // Stops the timer and cleans up
  void deleteTimer() {
    printd('Stopping and deleting timer');
    timer?.cancel();
    timer = null;
    state = Duration(seconds: -1);
  }

  // Disposes of the state notifier and its resources
  @override
  void dispose() {
    printd('Disposing WaitingUserCallTimeListStateNotifier');
    deleteTimer();
    super.dispose();
  }
}

final waitingUserCallTimeListProvider =
    StateNotifierProvider<WaitingUserCallTimeListStateNotifier, Duration?>(
  (ref) => WaitingUserCallTimeListStateNotifier(ref),
);
