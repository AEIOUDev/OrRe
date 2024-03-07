import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:orre/model/location_model.dart';

import '../../services/geocording/geocording_library_service.dart'; // 추가

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

  // 권한은 있으나 위치를 받아오지 못했을 때 사용할 팩토리 생성자
  UserLocation.cannotFindMyLocation()
      : isPermissionGranted = true,
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
  String? placemarks = await getAddressFromLatLngLibrary(
      position.latitude, position.longitude, 4, true);

  // 내 위치를 불러올 수 없을 때 팩토리 생성자 반환
  if (placemarks == null) {
    return UserLocation.cannotFindMyLocation();
  } else {
    return UserLocation(
      isPermissionGranted: true,
      locationInfo: LocationModel(
          locationName: 'nowLocation',
          address: placemarks,
          latitude: position.latitude,
          longitude: position.longitude),
    );
  }
});
