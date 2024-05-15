import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

final networkStateProvider = Provider<Stream<bool>>((ref) {
  return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
});

final networkStateNotifierProvider =
    StateNotifierProvider<NetworkStateNotifier, bool>((ref) {
  return NetworkStateNotifier(ref);
});

class NetworkStateNotifier extends StateNotifier<bool> {
  late final Ref ref;

  NetworkStateNotifier(this.ref) : super(false) {
    _checkNetworkStatus();
  }

  void _checkNetworkStatus() {
    ref.watch(networkStateProvider).listen((isConnected) {
      if (state != isConnected) {
        state = isConnected;
      }
    });
  }
}
