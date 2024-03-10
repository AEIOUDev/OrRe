import 'package:orre/model/location_model.dart';
import 'package:orre/provider/my_waiting_state_notifier.dart';

import 'menu_info_model.dart';
import 'user_info_model.dart';

// 모델
class StoreInfo {
  final String storeCode;
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
      locationInfo: LocationInfo.fromJson(json['locationInfo']),
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
