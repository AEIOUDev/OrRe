import 'package:equatable/equatable.dart';

import 'location_model.dart';

import 'menu_info_model.dart';
import 'user_info_model.dart';

// 모델
class StoreDetailInfo extends Equatable {
  final String storeImageMain;
  final int storeCode;
  final String storeName;
  final String storeIntroduce;
  final String storeCategory;
  final int storeInfoVersion;
  final int waitingAvailable;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;
  final DateTime openingTime;
  final DateTime closingTime;
  final DateTime lastOrderTime;
  final DateTime breakStartTime;
  final DateTime breakEndTime;
  final String storePhoneNumber;
  final LocationInfo locationInfo;
  final List<MenuInfo> menuInfo;
  final MenuCategories menuCategories;

  StoreDetailInfo({
    required this.storeImageMain,
    required this.storeCode,
    required this.storeName,
    required this.storeIntroduce,
    required this.storeCategory,
    required this.storeInfoVersion,
    required this.waitingAvailable,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
    required this.openingTime,
    required this.closingTime,
    required this.lastOrderTime,
    required this.breakStartTime,
    required this.breakEndTime,
    required this.storePhoneNumber,
    required this.locationInfo,
    required this.menuInfo,
    required this.menuCategories,
  });

  factory StoreDetailInfo.fromJson(Map<String, dynamic> json) {
    final openingTime = timeFromJson(json['openingTime'] ?? '');
    // print('openingTime: $openingTime');
    DateTime closingTime = timeFromJson(json['closingTime'] ?? '');
    closingTime = timeAdjust(openingTime, closingTime);
    // print('closingTime: $closingTime');

    final lastOrderTime = timeFromJson(json['lastOrderTime'] ?? '');
    // print('lastOrderTime: $lastOrderTime');

    final breakStartTime =
        timeFromJson(json['startBreakTime'] ?? (json['closingTime'] ?? ''));
    // print('breakStartTime: $breakStartTime');
    DateTime breakEndTime =
        timeFromJson(json['endBreakTime'] ?? (json['openingTime'] ?? ''));
    breakEndTime = timeAdjust(breakStartTime, breakEndTime);
    // print('breakEndTime: $breakEndTime');

    final locationLatitude = json['locationInfo'][0]['latitude'] ?? '';
    // print("locationLatitude: $locationLatitude");
    final locationLongitude = json['locationInfo'][0]['longitude'] ?? '';
    // print("locationLongitude: $locationLongitude");
    final locationName = json['locationInfo'][0]['storeName'] ?? '';
    // print("locationName: $locationName");
    final locationAddress = json['locationInfo'][0]['address'] ?? '';
    // print("locationAddress: $locationAddress");

    // print("categories : ${json['menuCategories']}");
    final menuCategories =
        MenuCategories.fromJson(json['menuCategories'] ?? {});
    // print("menuCategories: $menuCategories");

    return StoreDetailInfo(
      storeImageMain: json['storeImageMain'] ?? '',
      storeCode: json['storeCode'] ?? 0,
      storeName: json['storeName'] ?? '',
      storeIntroduce: json['storeIntroduce'] ?? '',
      storeCategory: json['storeCategory'] ?? '',
      storeInfoVersion: json['storeInfoVersion'] ?? 0,
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'] ?? 0,
      estimatedWaitingTime: json['estimatedWaitingTime'] ?? 0,
      waitingAvailable: json['waitingAvailable'] ?? 0,
      openingTime: openingTime,
      closingTime: closingTime,
      lastOrderTime: lastOrderTime,
      breakStartTime: breakStartTime,
      breakEndTime: breakEndTime,
      storePhoneNumber: json['storePhoneNumber'] ?? '',
      locationInfo: LocationInfo(
        locationName: locationName,
        latitude: locationLatitude,
        longitude: locationLongitude,
        address: locationAddress,
      ),
      menuInfo: List<MenuInfo>.from(
          json['menuInfo'].map((x) => MenuInfo.fromJson(x))),
      menuCategories: menuCategories,
    );
  }

  Map<String, dynamic> toJson() => {
        'storeImageMain': storeImageMain,
        'storeCode': storeCode,
        'storeName': storeName,
        'storeIntroduce': storeIntroduce,
        'storeCategory': storeCategory,
        'storeInfoVersion': storeInfoVersion,
        'numberOfTeamsWaiting': numberOfTeamsWaiting,
        'estimatedWaitingTime': estimatedWaitingTime,
        'waitingAvailable': waitingAvailable,
        'openingTime': openingTime.toIso8601String(),
        'closingTime': closingTime.toIso8601String(),
        'lastOrderTime': lastOrderTime.toIso8601String(),
        'breakStartTime': breakStartTime.toIso8601String(),
        'breakEndTime': breakEndTime.toIso8601String(),
        'storePhoneNumber': storePhoneNumber,
        'locationInfo': locationInfo,
        'menuInfo':
            List<dynamic>.from(menuInfo.map((x) => x.toJson())).toString(),
        'menuCategories': menuCategories.toJson(),
      };

  static nullValue() {
    return StoreDetailInfo(
      storeImageMain: '',
      storeCode: 0,
      storeName: '',
      storeIntroduce: '',
      storeCategory: '',
      storeInfoVersion: 0,
      numberOfTeamsWaiting: 0,
      estimatedWaitingTime: 0,
      waitingAvailable: 0,
      openingTime: DateTime.now(),
      closingTime: DateTime.now(),
      lastOrderTime: DateTime.now(),
      breakStartTime: DateTime.now(),
      breakEndTime: DateTime.now(),
      storePhoneNumber: '',
      locationInfo: LocationInfo(
        locationName: '',
        latitude: 0.0,
        longitude: 0.0,
        address: '',
      ),
      menuInfo: [],
      menuCategories: MenuCategories.nullValue(),
    );
  }

  static DateTime timeFromJson(String time) {
    // print("time: $time");
    if (time == '') {
      return DateTime.now();
    }
    final timeParts = time.split(':');
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      int.parse(timeParts[2]),
    );
  }

  static DateTime timeAdjust(DateTime startTime, DateTime endTime) {
    if (startTime.isAfter(endTime)) {
      return endTime.add(Duration(days: 1));
    }
    return endTime;
  }

  @override
  List<Object?> get props => [
        storeImageMain,
        storeCode,
        storeName,
        storeIntroduce,
        storeCategory,
        storeInfoVersion,
        waitingAvailable,
        numberOfTeamsWaiting,
        estimatedWaitingTime,
        openingTime,
        closingTime,
        lastOrderTime,
        breakStartTime,
        breakEndTime,
        storePhoneNumber,
        locationInfo,
        menuInfo,
        menuCategories,
      ];
}

class TableInfo extends Equatable {
  final String tableCode;
  final UserSimpleInfo userSimpleInfo;
  final List<OrderedMenuList> orderedMenuList;

  TableInfo(
      {required this.tableCode,
      required this.userSimpleInfo,
      required this.orderedMenuList});

  @override
  List<Object?> get props => [tableCode, userSimpleInfo, orderedMenuList];
}
