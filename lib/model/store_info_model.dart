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
  final List<MenuInfo> menuInfo;

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
      menuInfo: List<MenuInfo>.from(
          json['menuInfo'].map((x) => MenuInfo.fromJson(x))),
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

class TableInfo {
  final String tableCode;
  final UserSimpleInfo userSimpleInfo;
  final List<OrderedMenuList> orderedMenuList;

  TableInfo(
      {required this.tableCode,
      required this.userSimpleInfo,
      required this.orderedMenuList});
}
