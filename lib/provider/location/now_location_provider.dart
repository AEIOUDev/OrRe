import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import '../../services/geocording/geocording_library_service.dart'; // 추가

final nowLocationProvider =
    StateNotifierProvider<LocationStateNotifier, LocationInfo?>((ref) {
  return LocationStateNotifier(ref);
});

class LocationStateNotifier extends StateNotifier<LocationInfo?> {
  late final Ref _ref;
  LocationStateNotifier(this._ref) : super(null) {}

  Future<LocationInfo?> updateNowLocation() async {
    print("nowLocationProvider updateNowLocation");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // 권한 거부되었을 때의 상태 반환
        print("위치 권한 거부 : $permission");
        state = null;
        return null;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print("위치 권한 허용 : $permission");
      }
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    print(
        "nowLocationProvider : 현재 경도 : ${position.longitude}, 현재 위도 : ${position.latitude}");

    // 권한이 허용되었을 때 도로명 주소 변환 로직
    final temp = await getAddressFromLatLngLibrary(
        position.latitude, position.longitude, 4, true);
    String? placemarks = temp.first;

    // 내 도로명 주소를 불러올 수 없을 때의 상태 반환
    if (placemarks == null) {
      print("현재 위치의 주소를 찾을 수 없습니다.");
      state = LocationInfo(
        locationName: '현재 위치',
        address: '주소를 찾을 수 없습니다.',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } else {
      print("nowLocationProvider : $placemarks");
      state = LocationInfo(
          locationName: '현재 위치',
          address: placemarks,
          latitude: position.latitude,
          longitude: position.longitude);
    }
    _ref.read(locationListProvider.notifier).updateNowLocation(state!);
    return state;
  }
}
