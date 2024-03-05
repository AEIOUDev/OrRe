import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:orre/model/location_model.dart'; // 추가

class UserLocation {
  final bool isPermissionGranted; // 위치 권한 상태
  final LocationModel? locationInfo;

  UserLocation({
    required this.isPermissionGranted,
    required this.locationInfo,
  });

  // 권한이 거부되었을 때 사용할 팩토리 생성자
  UserLocation.permissionDenied()
      : isPermissionGranted = false,
        locationInfo = null;
}

final locationProvider = FutureProvider<UserLocation>((ref) async {
  print("locationProvider");
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // 권한 거부되었을 때의 상태 반환
      return UserLocation.permissionDenied();
    }
  }

  final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  // 권한이 허용되었을 때 도로명 주소 변환 로직
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  String address = placemarks.isNotEmpty
      ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.postalCode}, ${placemarks.first.country}"
      : "unknown";

  return UserLocation(
    isPermissionGranted: true,
    locationInfo: LocationModel(
        locationName: 'nowLocation',
        address: address,
        latitude: position.latitude,
        longitude: position.longitude),
  );
});
