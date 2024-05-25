import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';

import '../../model/location_model.dart';
import 'now_location_provider.dart';

class LocationListNotifier extends StateNotifier<LocationState> {
  late Ref ref;
  LocationListNotifier(Ref _ref) : super(LocationState()) {
    ref = _ref;
    _init();
  }

  final _storage = FlutterSecureStorage();

  Future<void> _init() async {
    await loadLocations();

    // nowLocationProvider를 사용하여 현재 위치 업데이트
    ref
        .read(nowLocationProvider.notifier)
        .updateNowLocation()
        .then((userLocationInfo) {
      if (userLocationInfo != null) {
        updateNowLocation(userLocationInfo);
      } else {
        print("Error fetching now location");
      }
    }).catchError((error) {
      // 오류 처리
      print("Error fetching now location: $error");
    });
  }

  // 새로운 위치를 리스트에 추가
  Future<void> addLocation(LocationInfo locationInfo) async {
    print("addLocation");

    if (locationInfo.locationName == "현재 위치") {
      print("nowLocation cannot be added as a custom location");
      return;
    }

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
    print("saveLocations : $stringList");
    await _storage.write(key: 'savedLocations', value: json.encode(stringList));
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadLocations() async {
    print("loadLocations");
    try {
      if (_storage.containsKey(key: 'savedLocations') == false) {
        print("savedLocations not found");
        state = LocationState(customLocations: [], selectedLocation: null);
        return;
      }

      String? stringListJson = await _storage.read(key: 'savedLocations');
      if (stringListJson != null) {
        List<dynamic> stringList = json.decode(stringListJson);
        List<LocationInfo> loadedLocations = stringList
            .map((string) => LocationInfo.fromJson(json.decode(string)))
            .toList();
        // 초기 선택된 위치 설정 로직 추가 가능
      } else {
        // 초기 상태 설정 또는 기본값 사용
        print("No data found for savedLocations");
      }
    } catch (e) {
      print("Error reading from Keychain: $e");
      // 에러 처리 로직 추가 (예: 상태 초기화 또는 사용자에게 알림)
    }
  }

  // "nowLocation"을 현재 위치 정보로 업데이트하는 메서드
  Future<void> updateNowLocation(LocationInfo newLocation) async {
    print("updateNowLocation " + newLocation.locationName);
    // 상태를 업데이트합니다.
    state = state.copyWith(nowLocation: newLocation);
    print("locationListProvider : ${state.selectedLocation?.locationName}");
    selectLocation(newLocation);
    // 변경된 위치 정보를 저장합니다.
    saveLocations();
  }

  // 선택된 위치를 업데이트하는 메서드
  void selectLocation(LocationInfo location) {
    ref.read(storeWaitingInfoNotifierProvider.notifier).unSubscribeAll();
    print("selectLocation");
    print(location.locationName);
    state = state.copyWith(selectedLocation: location);
  }

  void selectLocationToNowLocation() {
    final newState = state.copyWith(selectedLocation: state.nowLocation);
    state = newState;
  }
}

// 위치 정보 리스트를 관리하는 Provider
final locationListProvider =
    StateNotifierProvider<LocationListNotifier, LocationState>((ref) {
  return LocationListNotifier(ref);
});
