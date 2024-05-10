import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

final networkStreamProvider = StreamProvider<bool>((ref) {
  return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
});

final networkStateNotifier = StateNotifierProvider<NetworkStateNotifier, bool>(
    (ref) => NetworkStateNotifier());

class NetworkStateNotifier extends StateNotifier<bool> {
  NetworkStateNotifier() : super(true) {
    ConnectivityChecker(interval: const Duration(seconds: 5))
        .stream
        .listen((event) {
      state = event;
    });
  }
}
