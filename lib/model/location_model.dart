class LocationModel {
  final String locationName; // 장소 이름
  final double latitude; // 위도
  final double longitude; // 경도
  final String address; // 도로명 주소 추가

  LocationModel({
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

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      locationName: json['locationName'],
    );
  }
}
