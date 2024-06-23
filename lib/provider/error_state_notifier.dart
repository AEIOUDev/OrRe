import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/debug_services.dart';

enum Error {
  none,
  network,
  websocket,
  locationPermission,
  callPermission,
  server,
}

final errorStateNotifierProvider =
    StateNotifierProvider<ErrorStateNotifier, List<Error>>((ref) {
  return ErrorStateNotifier();
});

class ErrorStateNotifier extends StateNotifier<List<Error>> {
  ErrorStateNotifier() : super([]);

  void addError(Error error) {
    printd("addError : $error");
    state = [...state, error];
  }

  void deleteError(Error error) {
    printd("deleteError : $error");

    if (state.isEmpty) {
      return;
    }

    final newState = state.where((e) => e != error).toList();
    state = newState;
  }

  bool findError(Error error) {
    return state.contains(error);
  }

  bool get hasError => state.isNotEmpty;
}
