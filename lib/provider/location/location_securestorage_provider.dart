import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../model/location_model.dart';
import '../../services/debug_services.dart';
import 'now_location_provider.dart';

// 위치 정보 리스트를 관리하는 Provider
final locationListProvider =
    StateNotifierProvider<LocationListNotifier, LocationState>((ref) {
  return LocationListNotifier(ref);
});

class LocationListNotifier extends StateNotifier<LocationState> {
  late Ref ref;
  LocationListNotifier(Ref _ref) : super(LocationState()) {
    ref = _ref;
    // _init();
  }

  final _storage = FlutterSecureStorage();

  Future<void> init() async {
    printd("LocationListNotifier 초기화 시작");
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

    // 이미 같은 이름의 위치가 있는지 확인하고, 있으면 좌표만 업데이트
    if (state.customLocations.any(
        (location) => location.locationName == locationInfo.locationName)) {
      print("Location already exists. Updating coordinates.");
      final updatedLocations = state.customLocations
          .map((location) => location.locationName == locationInfo.locationName
              ? locationInfo
              : location)
          .toList();
      // 그리고 해당 위치가 선택된 위치였다면, 선택된 위치도 업데이트
      if (state.selectedLocation?.locationName == locationInfo.locationName) {
        state = state.copyWith(
            customLocations: updatedLocations, selectedLocation: locationInfo);
      } else {
        state = state.copyWith(customLocations: updatedLocations);
      }
      await saveLocations();
      return;
    } else {
      print("Location does not exist. Adding new location.");
    }

    final updatedLocations = List<LocationInfo>.from(state.customLocations)
      ..add(locationInfo);
    state = state.copyWith(customLocations: updatedLocations);
    await saveLocations();
  }

  // 지정된 이름의 위치 정보 제거
  Future<void> removeLocation(String locationName) async {
    print("removeLocation");

    // 선택된 위치가 삭제되는 위치와 다른 위치만 남기기
    List<LocationInfo> updatedLocations = state.customLocations
        .where((location) => location.locationName != locationName)
        .toList();

    printd("updatedLocations : ${updatedLocations.toString()}");

    // 선택된 위치가 삭제되는 위치와 같은지 확인
    LocationInfo? updatedSelectedLocation =
        state.selectedLocation?.locationName == locationName
            ? null
            : state.selectedLocation;

    printd("updatedSelectedLocation : ${updatedSelectedLocation.toString()}");

    // 만약 삭제한 위치가 selectedLocation이라면, 현재 위치를 선택된 위치로 설정
    if (updatedSelectedLocation == null) {
      await selectLocationToNowLocation();
    }

    state = state.copyWith(
        customLocations: updatedLocations,
        selectedLocation: updatedSelectedLocation);

    printd("state : ${state.customLocations.toString()}");
    printd("state : ${state.selectedLocation.toString()}");

    await saveLocations(); // 변경 사항 저장
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveLocations() async {
    printd("saveSelectedLocation : ${state.selectedLocation}");
    printd("saveCustomLocations : ${state.customLocations}");

    List<String> stringList = state.customLocations
        .map((location) => json.encode(location.toJson()))
        .toList();
    String selectedLocationJson = json.encode(state.selectedLocation?.toJson());

    print("saveSelectedLocation : $selectedLocationJson");
    print("saveCustomLocations : $stringList");

    await _storage.write(
        key: 'savedCustomLocations', value: json.encode(stringList));
    await _storage.write(
        key: 'savedSelectedLocation', value: selectedLocationJson);
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadLocations() async {
    print("loadLocations");
    try {
      if (_storage.containsKey(key: 'savedCustomLocations') == false) {
        print("savedCustomLocations not found");
        state = LocationState(customLocations: [], selectedLocation: null);
        return;
      }
      if (_storage.containsKey(key: 'savedSelectedLocation') == false) {
        print("savedSelectedLocation not found");
        state = LocationState(customLocations: [], selectedLocation: null);
        return;
      }

      printd(
          "loadLocations : savedCustomLocations && saveSelectedLocation found");
      String? stringListJson = await _storage.read(key: 'savedCustomLocations');
      String? selectedLocationJson =
          await _storage.read(key: 'savedSelectedLocation');

      if (stringListJson != null) {
        List<dynamic> stringList = json.decode(stringListJson);
        List<LocationInfo> loadedLocations = stringList
            .where((string) => string != null) // null 값 필터링
            .map((string) => LocationInfo.fromJson(json.decode(string)))
            .toList();
        // 초기 선택된 위치 설정 로직 추가 가능
        state = state.copyWith(customLocations: loadedLocations);
        printd("customLocations : ${state.customLocations.length}");
      } else {
        // 초기 상태 설정 또는 기본값 사용
        print("No data found for savedCustomLocations");
      }

      if (selectedLocationJson != null) {
        final decodedJson = json.decode(selectedLocationJson);
        if (decodedJson is Map<String, dynamic>) {
          LocationInfo selectedLocation = LocationInfo.fromJson(decodedJson);
          state = state.copyWith(selectedLocation: selectedLocation);
          printd("selectedLocation : ${state.selectedLocation?.locationName}");
        } else {
          print("Invalid JSON format for selectedLocationJson");
        }
      } else {
        // 초기 상태 설정 또는 기본값 사용
        print("No data found for savedSelectedLocation");
      }
    } catch (e) {
      print("Error reading from Keychain: $e");
      // 에러 처리 로직 추가 (예: 상태 초기화 또는 사용자에게 알림)
    }
  }

  // "nowLocation"을 현재 위치 정보로 업데이트하는 메서드
  Future<void> updateNowLocation(LocationInfo newLocation) async {
    await loadLocations();
    print("updateNowLocation " + newLocation.locationName);
    // 상태를 업데이트합니다.
    state = state.copyWith(nowLocation: newLocation);
    print("locationListProvider : ${state.selectedLocation?.locationName}");
    // selectLocation(newLocation);
    // 변경된 위치 정보를 저장합니다.
    await saveLocations();
  }

  // 선택된 위치를 업데이트하는 메서드
  void selectLocation(LocationInfo location) async {
    await loadLocations();
    print("selectLocation");
    print(location.locationName);
    state = state.copyWith(selectedLocation: location);
    printd("state : ${state.selectedLocation?.locationName}");
    printd("state : ${state.customLocations.length}");
    await saveLocations();
  }

  Future<void> selectLocationToNowLocation() async {
    await loadLocations();
    final newState = state.copyWith(selectedLocation: state.nowLocation);
    state = newState;
    await saveLocations();
  }

  LocationInfo? getSelectedLocation() => state.selectedLocation;
  LocationInfo? getNowLocation() => state.nowLocation;
  List<LocationInfo> getCustomLocations() => state.customLocations;
}
