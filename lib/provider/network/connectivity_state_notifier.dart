import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:orre/provider/error_state_notifier.dart';

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
        if (isConnected) {
          print("networkStateNotifierProvider is connected");
          ref
              .read(errorStateNotifierProvider.notifier)
              .deleteError(Error.network);
        } else {
          print("networkStateNotifierProvider is disconnected");
          ref.read(errorStateNotifierProvider.notifier).addError(Error.network);
        }
      }
    });
  }
}
