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
  final List<LocationInfo> locations;
  final LocationInfo? selectedLocation;
  final LocationInfo? nowLocation;
  final bool isDuplicate;

  LocationState({
    this.locations = const [],
    this.selectedLocation,
    this.nowLocation,
    this.isDuplicate = false,
  });

  LocationState copyWith({
    List<LocationInfo>? locations,
    LocationInfo? selectedLocation,
    LocationInfo? nowLocation,
    bool? isDuplicate,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      nowLocation: nowLocation ?? this.nowLocation,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }
}
