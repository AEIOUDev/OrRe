import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

final networkStateProvider = Provider<Stream<bool>>((ref) {
  return ConnectivityChecker(interval: const Duration(seconds: 5)).stream;
});
