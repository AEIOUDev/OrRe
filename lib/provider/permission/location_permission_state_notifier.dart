import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final locationPermissionStateNotifierProvider =
    StateNotifierProvider<LocationPermissionStateNotifier, PermissionStatus>(
  (ref) => LocationPermissionStateNotifier(),
);

class LocationPermissionStateNotifier extends StateNotifier<PermissionStatus> {
  LocationPermissionStateNotifier() : super(PermissionStatus.denied) {
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    state = status;
  }
}
