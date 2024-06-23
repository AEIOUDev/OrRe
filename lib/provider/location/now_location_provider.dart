import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
// import 'package:orre/services/geocording/naver_map_services.dart';
import '../../services/debug_services.dart';
import '../../services/geocording/geocording_library_service.dart';

final nowLocationProvider =
    StateNotifierProvider<LocationStateNotifier, LocationInfo?>((ref) {
  return LocationStateNotifier(ref);
});

class LocationStateNotifier extends StateNotifier<LocationInfo?> {
  late final Ref _ref;
  LocationStateNotifier(this._ref) : super(null) {}

  Future<LocationInfo?> updateNowLocation() async {
    printd("nowLocationProvider updateNowLocation");

    Position position = Position(
      latitude: 37.5665,
      longitude: 126.9780,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } catch (e) {
      printd("nowLocationProvider Error : $e");
      return null;
    }

    printd(
        "nowLocationProvider : 현재 경도 : ${position.longitude}, 현재 위도 : ${position.latitude}");

    // state와 현재 좌표가 크게 다를 때만 state를 업데이트
    if (state != null) {
      LocationInfo locationInfo = state as LocationInfo;
      if ((locationInfo.latitude - locationInfo.latitude).abs() < 0.00001 &&
          (locationInfo.longitude - locationInfo.longitude).abs() < 0.00001) {
        printd("nowLocationProvider : 위치가 변경되지 않았습니다.");

        // 거리 차이 printd
        printd(
            "nowLocationProvider : 위도 차이 : ${(locationInfo.latitude - position.latitude).abs()}");

        printd(
            "nowLocationProvider : 경도 차이 : ${(locationInfo.longitude - position.longitude).abs()}");

        printd(
            "총 거리 : ${(locationInfo.latitude - position.latitude).abs() + (locationInfo.longitude - position.longitude).abs()}");
        return state;
      }
    }

    // 권한이 허용되었을 때 도로명 주소 변환 로직
    final temp = await getAddressFromLatLngLibrary(
        position.latitude, position.longitude, 4, true);
    // final temp = await getAddressFromLatLngNaver(
    // position.latitude, position.longitude, 4, true);
    printd("nowLocationProvier getAddr : $temp");
    // final temp = await getAddressFromLatLngNaver(
    //     position.latitude, position.longitude, 4, true);
    String? placemarks = temp.last;

    // 내 도로명 주소를 불러올 수 없을 때의 상태 반환
    if (placemarks == null) {
      printd("현재 위치의 주소를 찾을 수 없습니다.");
      state = LocationInfo(
        locationName: '현재 위치',
        address: '주소를 찾을 수 없습니다.',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } else {
      printd("nowLocationProvider : $placemarks");
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
