import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingUserCallTimeListStateNotifier extends StateNotifier<Duration?> {
  DateTime? userCallTime;
  Timer? timer;
  late Ref ref;

  WaitingUserCallTimeListStateNotifier(this.ref) : super(null);

  // Sets the user call time and starts a timer to update the remaining time
  void setUserCallTime(DateTime userCallTime) {
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

    final currentTime = DateTime.now();
    final difference = userCallTime!.difference(currentTime);

    // Debug print to check the time difference
    print('Time difference: $difference');

    if (difference.isNegative) {
      deleteTimer();
    } else {
      state = difference;
    }
  }

  // Stops the timer and cleans up
  void deleteTimer() {
    print('Stopping and deleting timer');
    timer?.cancel();
    timer = null;
    state = null; // Optionally reset state to null when the timer is stopped
  }

  // Disposes of the state notifier and its resources
  @override
  void dispose() {
    print('Disposing WaitingUserCallTimeListStateNotifier');
    deleteTimer();
    super.dispose();
  }
}

final waitingUserCallTimeListProvider =
    StateNotifierProvider<WaitingUserCallTimeListStateNotifier, Duration?>(
  (ref) => WaitingUserCallTimeListStateNotifier(ref),
);
