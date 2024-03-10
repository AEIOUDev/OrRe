import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orre/model/location_model.dart';

import '../../model/user_info_model.dart';
import '../../services/geocording/geocording_library_service.dart'; // 추가

final locationProvider = FutureProvider<UserLocationInfo>((ref) async {
  print("locationProvider");
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // 권한 거부되었을 때의 상태 반환
      return UserLocationInfo.permissionDenied();
    }
  }

  final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  // 권한이 허용되었을 때 도로명 주소 변환 로직
  String? placemarks = await getAddressFromLatLngLibrary(
      position.latitude, position.longitude, 4, true);

  // 내 위치를 불러올 수 없을 때 팩토리 생성자 반환
  if (placemarks == null) {
    return UserLocationInfo.cannotFindUserLocation();
  } else {
    return UserLocationInfo(
      isPermissionGranted: true,
      locationInfo: LocationInfo(
          locationName: 'nowLocation',
          address: placemarks,
          latitude: position.latitude,
          longitude: position.longitude),
    );
  }
});
