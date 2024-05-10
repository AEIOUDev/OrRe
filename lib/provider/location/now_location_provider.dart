import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orre/model/location_model.dart';
import '../../services/geocording/geocording_library_service.dart'; // 추가

final nowLocationProvider =
    StateNotifierProvider<LocationStateNotifier, LocationInfo>((ref) {
  return LocationStateNotifier(ref);
});

class LocationStateNotifier extends StateNotifier<LocationInfo> {
  LocationStateNotifier(Ref _ref) : super(LocationInfo.nullValue()) {}

  Future<LocationInfo> updateNowLocation() async {
    print("nowLocationProvider");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // 권한 거부되었을 때의 상태 반환
        print("permission denied");
        state = LocationInfo.nullValue();
        return LocationInfo.nullValue();
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print("permission granted");
      }
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    print(position.latitude);

    // 권한이 허용되었을 때 도로명 주소 변환 로직
    String? placemarks = await getAddressFromLatLngLibrary(
        position.latitude, position.longitude, 4, true);

    // 내 위치를 불러올 수 없을 때 팩토리 생성자 반환
    if (placemarks == null) {
      print("cannot find user location");
      state = LocationInfo.nullValue();
      return LocationInfo.nullValue();
    } else {
      print("nowLocationProvider : $placemarks");
      final locationInfo = LocationInfo(
          locationName: 'nowLocation',
          address: placemarks,
          latitude: position.latitude,
          longitude: position.longitude);
      state = locationInfo;
      return locationInfo;
    }
  }
}
