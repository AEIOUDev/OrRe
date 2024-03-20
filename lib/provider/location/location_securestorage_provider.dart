import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/location_model.dart';
import 'now_location_provider.dart';

class LocationListNotifier extends StateNotifier<LocationState> {
  LocationListNotifier(Ref ref) : super(LocationState()) {
    _init(ref);
  }

  final _storage = FlutterSecureStorage();

  Future<void> _init(Ref ref) async {
    await loadLocations();

    // nowLocationProvider를 사용하여 현재 위치 업데이트
    ref.read(nowLocationProvider.future).then((userLocationInfo) {
      updateNowLocation(userLocationInfo.locationInfo!);
    }).catchError((error) {
      // 오류 처리
      print("Error fetching now location: $error");
    });
  }

  // 새로운 위치를 리스트에 추가
  Future<void> addLocation(LocationInfo locationInfo) async {
    print("addLocation");

    final updatedLocations = List<LocationInfo>.from(state.customLocations)
      ..add(locationInfo);
    state = state.copyWith(customLocations: updatedLocations);
    saveLocations();
  }

  // 지정된 이름의 위치 정보 제거
  Future<void> removeLocation(String locationName) async {
    print("removeLocation");
    List<LocationInfo> updatedLocations = state.customLocations
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
        customLocations: updatedLocations,
        selectedLocation: updatedSelectedLocation);

    saveLocations(); // 변경 사항 저장
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveLocations() async {
    print("saveLocations");
    List<String> stringList = state.customLocations
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
        customLocations: loadedLocations,
        selectedLocation: initialSelectedLocation);
  }

  // "nowLocation"을 현재 위치 정보로 업데이트하는 메서드
  Future<void> updateNowLocation(LocationInfo newLocation) async {
    print("updateNowLocation " + newLocation.locationName);
    // "nowLocation"을 찾습니다.
    int index = state.customLocations
        .indexWhere((loc) => loc.locationName == "nowLocation");

    List<LocationInfo> updatedLocations = List.from(state.customLocations);

    if (index != -1) {
      // "nowLocation"이 이미 존재한다면, 해당 위치를 업데이트합니다.
      updatedLocations[index] = newLocation;
    } else {
      // "nowLocation"이 존재하지 않는다면, 리스트의 시작 부분에 추가합니다.
      updatedLocations.insert(0, newLocation);
    }

    // 상태를 업데이트합니다.
    state = state.copyWith(
        customLocations: updatedLocations,
        selectedLocation: newLocation,
        nowLocation: newLocation);
    print("locationListProvider : ${state.selectedLocation?.locationName}");
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
