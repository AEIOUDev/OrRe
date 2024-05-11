import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

final networkStreamProvider = StreamProvider<bool>((ref) {
  return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
});

final networkStateNotifier = StateNotifierProvider<NetworkStateNotifier, bool>(
    (ref) => NetworkStateNotifier());

class NetworkStateNotifier extends StateNotifier<bool> {
  NetworkStateNotifier() : super(false) {
    updateNetworkState();
  }

  void updateNetworkState() async {
    ConnectivityChecker(interval: const Duration(seconds: 5))
        .stream
        .listen((event) {
      print("NetworkStateNotifier: $event");
      state = event;
    });
  }
}
