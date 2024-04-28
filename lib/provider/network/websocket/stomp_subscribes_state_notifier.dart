import 'package:flutter_riverpod/flutter_riverpod.dart';

class StompSubscribesStateNotifier extends StateNotifier<List<String>> {
  StompSubscribesStateNotifier(List<String> initialState) : super(initialState);

  void addSubscribe(String subscribe) {
    state = [...state, subscribe];
  }

  void removeSubscribe(String subscribe) {
    state = state.where((element) => element != subscribe).toList();
  }

  void clearSubscribes() {
    state = [];
  }
}

final stompSubscribesStateNotifierProvider =
    StateNotifierProvider<StompSubscribesStateNotifier, List<String>>((ref) {
  return StompSubscribesStateNotifier([]);
});
