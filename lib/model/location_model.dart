class LocationInfo {
  final String locationName; // 장소 이름
  final double latitude; // 위도
  final double longitude; // 경도
  final String address; // 도로명 주소 추가

  LocationInfo({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.address, // 새로 추가
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'locationName': locationName,
      };

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      locationName: json['locationName'],
    );
  }
}

// 새로운 상태 클래스 정의
class LocationState {
  final LocationInfo? nowLocation;
  final LocationInfo? selectedLocation;
  final List<LocationInfo> customLocations;

  LocationState({
    this.nowLocation,
    this.selectedLocation,
    this.customLocations = const [],
  });

  LocationState copyWith({
    LocationInfo? nowLocation,
    LocationInfo? selectedLocation,
    List<LocationInfo>? customLocations,
  }) {
    return LocationState(
      nowLocation: nowLocation ?? this.nowLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      customLocations: customLocations ?? this.customLocations,
    );
  }
}
