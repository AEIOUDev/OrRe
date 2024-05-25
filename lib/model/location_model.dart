import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:orre/services/debug.services.dart';

class LocationInfo extends Equatable {
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

  int operator -(Object other) {
    const double earthRadius = 6371; // in kilometers

    if (other is LocationInfo) {
      double lat1 = latitude;
      double lon1 = longitude;
      double lat2 = other.latitude;
      double lon2 = other.longitude;

      double dLat = _toRadians(lat2 - lat1);
      double dLon = _toRadians(lon2 - lon1);

      double a = pow(sin(dLat / 2), 2) +
          cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));

      double distance = earthRadius * c * 1000; // in meters
      distance = double.parse(distance.toStringAsFixed(2));
      printd("distance: $distance");
      return distance.toInt();
    } else {
      return -1;
    }
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [locationName, latitude, longitude, address];
}

// 새로운 상태 클래스 정의
class LocationState extends Equatable {
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

  @override
  // TODO: implement props
  List<Object?> get props => [nowLocation, selectedLocation, customLocations];
}
