import 'package:orre/model/location_model.dart';

import 'menu_info_model.dart';
import 'user_info_model.dart';

// 모델
class StoreDetailInfo {
  final String storeImageMain;
  final int storeCode;
  final String storeName;
  final String storeIntroduce;
  final String storeCategory;
  final int storeInfoVersion;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;
  final List<dynamic> menuInfo;

  StoreDetailInfo({
    required this.storeImageMain,
    required this.storeCode,
    required this.storeName,
    required this.storeIntroduce,
    required this.storeCategory,
    required this.storeInfoVersion,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
    required this.menuInfo,
  });

  factory StoreDetailInfo.fromJson(Map<String, dynamic> json) {
    return StoreDetailInfo(
      storeImageMain: json['storeImageMain'],
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeIntroduce: json['storeIntroduce'],
      storeCategory: json['storeCategory'],
      storeInfoVersion: json['storeInfoVersion'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
      menuInfo: json['menuInfo'],
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
        'menuInfo': menuInfo,
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
      menuInfo: [],
    );
  }
}

class StoreInfo {
  final int storeCode;
  final String storeName;
  final int storeInfoVersion;
  final LocationInfo locationInfo;
  final List<MenuInfo> menuList;

  StoreInfo({
    required this.storeCode,
    required this.storeName,
    required this.storeInfoVersion,
    required this.locationInfo,
    required this.menuList,
  });

  Map<String, dynamic> toJson() => {
        'storeCode': storeCode,
        'storeName': storeName,
        'storeInfoVersion': storeInfoVersion,
        'locationInfo': locationInfo.toJson(),
        'menuList': menuList.map((menu) => menu.toJson()).toList(),
      };

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeInfoVersion: json['storeInfoVersion'],
      locationInfo: LocationInfo(
          locationName: "", latitude: 0, longitude: 0, address: ""),
      menuList: List<MenuInfo>.from(
        json['menuList'].map((menu) => MenuInfo.fromJson(menu)),
      ),
    );
  }
}

class TableInfo {
  final String tableCode;
  final UserSimpleInfo userSimpleInfo;
  final List<OrderedMenuList> orderedMenuList;

  TableInfo(
      {required this.tableCode,
      required this.userSimpleInfo,
      required this.orderedMenuList});
}

class StoreWaitingInfo {
  final StoreInfo storeInfo;
  final List<int> nowEnteringNumbers;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;

  StoreWaitingInfo({
    required this.storeInfo,
    required this.nowEnteringNumbers,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
  });

  // JSON에서 Dart 객체 생성자
  factory StoreWaitingInfo.fromJson(Map<String, dynamic> json) {
    return StoreWaitingInfo(
      storeInfo: json['storeInfo'],
      nowEnteringNumbers: json['nowEnteringNumbers'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
    );
  }
}
