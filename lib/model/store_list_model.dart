import 'package:equatable/equatable.dart';

class StoreLocationInfo extends Equatable {
  final String storeImageMain;
  final int storeCode;
  final String storeName;
  final String storeShortIntroduce;
  final String storeCategory;
  final String address;
  final double distance;
  final double latitude;
  final double longitude;

  StoreLocationInfo({
    required this.storeImageMain,
    required this.storeCode,
    required this.storeName,
    required this.storeShortIntroduce,
    required this.storeCategory,
    required this.address,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory StoreLocationInfo.fromJson(Map<String, dynamic> json) {
    return StoreLocationInfo(
      storeImageMain: json['storeImageMain'],
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeShortIntroduce: json['storeShortIntroduce'],
      storeCategory: json['storeCategory'],
      address: json['address'],
      distance: json['distance'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'storeImageMain': storeImageMain,
        'storeCode': storeCode,
        'storeName': storeName,
        'storeShortIntroduce': storeShortIntroduce,
        'storeCategory': storeCategory,
        'address': address,
        'distance': distance,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [
        storeImageMain,
        storeCode,
        storeName,
        storeShortIntroduce,
        storeCategory,
        address,
        distance,
        latitude,
        longitude
      ];
}
