import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/location_model.dart';
import 'location_info_provider.dart';

class LocationListNotifier extends StateNotifier<LocationState> {
  LocationListNotifier(Ref ref) : super(LocationState()) {
    init(ref);
  }

  final _storage = FlutterSecureStorage(); // 안전한 저장소 인스턴스

  // 앱 시작 시 현재 위치 정보를 로드하고 "nowLocation"을 업데이트
  Future<void> init(Ref ref) async {
    print("_init");
    await loadLocations(); // 저장된 위치 정보 로드

    // 현재 위치 정보를 가져와 "nowLocation" 업데이트
    ref.read(locationProvider.future).then((userLocationInfo) async {
      if (userLocationInfo.isPermissionGranted &&
          userLocationInfo.locationInfo != null) {
        LocationInfo currentLocation = userLocationInfo.locationInfo!;
        if (currentLocation.address == "unknown") {
          // 주소가 유효하지 않은 경우 기본 주소 사용
          currentLocation = LocationInfo(
            locationName: "nowLocation",
            latitude: 0,
            longitude: 0,
            address: "기본 주소", // 기본 주소 설정
          );
        }
        // 현재 위치를 "nowLocation"으로 업데이트
        await updateNowLocation(currentLocation); // 현재 위치 업데이트
      }
    });
  }

  // 새로운 위치를 리스트에 추가
  Future<void> addLocation(LocationInfo locationInfo) async {
    print("addLocation");
    if (state.locations.any(
        (location) => location.locationName == locationInfo.locationName)) {
      // 중복된 이름이 있을 경우 상태 업데이트
      state = state.copyWith(isDuplicate: true);
      return;
    }
    // 중복된 이름이 없을 경우 위치 추가 및 상태 업데이트
    final updatedLocations = List<LocationInfo>.from(state.locations)
      ..add(locationInfo);
    state = state.copyWith(locations: updatedLocations, isDuplicate: false);
    saveLocations();
  }

  // 지정된 이름의 위치 정보 제거
  Future<void> removeLocation(String locationName) async {
    print("removeLocation");
    List<LocationInfo> updatedLocations = state.locations
        .where((location) => location.locationName != locationName)
        .toList();

    // "nowLocation"은 삭제되지 않도록 보장
    if (locationName == "nowLocation") {
      return;
    }

    // 선택된 위치가 삭제되는 위치와 같은지 확인
    LocationInfo? updatedSelectedLocation =
        state.selectedLocation?.locationName == locationName
            ? null
            : state.selectedLocation;

    state = state.copyWith(
        locations: updatedLocations, selectedLocation: updatedSelectedLocation);

    saveLocations(); // 변경 사항 저장
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveLocations() async {
    print("saveLocations");
    List<String> stringList = state.locations
        .map((location) => json.encode(location.toJson()))
        .toList();
    await _storage.write(key: 'savedLocations', value: json.encode(stringList));
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadLocations() async {
    print("loadLocations");
    String? stringListJson = await _storage.read(key: 'savedLocations');
    List<LocationInfo> loadedLocations = [];
    LocationInfo? initialSelectedLocation;

    if (stringListJson != null) {
      List<dynamic> stringList = json.decode(stringListJson);
      loadedLocations = stringList
          .map((string) => LocationInfo.fromJson(json.decode(string)))
          .toList();
      // 초기 선택된 위치를 설정할 수 있습니다.
    } else {
      // 초기 상태 설정 또는 기본값 사용
    }

    state = LocationState(
        locations: loadedLocations, selectedLocation: initialSelectedLocation);
  }

  // "nowLocation"을 현재 위치 정보로 업데이트하는 메서드
  Future<void> updateNowLocation(LocationInfo newLocation) async {
    print("updateNowLocation " + newLocation.locationName);
    // "nowLocation"을 찾습니다.
    int index =
        state.locations.indexWhere((loc) => loc.locationName == "nowLocation");

    List<LocationInfo> updatedLocations = List.from(state.locations);

    if (index != -1) {
      // "nowLocation"이 이미 존재한다면, 해당 위치를 업데이트합니다.
      updatedLocations[index] = newLocation;
    } else {
      // "nowLocation"이 존재하지 않는다면, 리스트의 시작 부분에 추가합니다.
      updatedLocations.insert(0, newLocation);
    }

    // 상태를 업데이트합니다.
    state = state.copyWith(
        locations: updatedLocations,
        selectedLocation: newLocation,
        nowLocation: newLocation);

    print(state.selectedLocation?.locationName);
    // 변경된 위치 정보를 저장합니다.
    saveLocations();
  }

  // 선택된 위치를 업데이트하는 메서드
  void selectLocation(LocationInfo location) {
    print("selectLocation");
    print(location.locationName);
    state = state.copyWith(selectedLocation: location);
  }
}

// 위치 정보 리스트를 관리하는 Provider
final locationListProvider =
    StateNotifierProvider<LocationListNotifier, LocationState>((ref) {
  return LocationListNotifier(ref);
});
