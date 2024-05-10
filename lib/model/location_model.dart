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

  static nullValue() {
    return LocationInfo(
      locationName: '보정동 카페거리',
      latitude: 37.32152732612146,
      longitude: 127.11053698988346,
      address: '경기도 용인시 기흥구 보정동 죽전로 15번길',
    );
  }

  // == 연산자 오버라이딩
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationInfo &&
        other.locationName == locationName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
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
