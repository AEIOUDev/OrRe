// 요청자의 정보를 담는 모델
import 'location_model.dart';
import 'store_info_model.dart';

class UserInfo {
  final String phoneNumber;
  final String password;
  final String name;
  final String fcmToken;
  final List<CreditInfo> creditInfo;
  final List<UserWaitingStoreInfo> userWaitingStoreInfo;
  final List<UserOrderingStoreInfo> userOrderingStoreInfo;
  final UserLocationInfo userLocationInfo;

  UserInfo(
      {required this.phoneNumber,
      required this.password,
      required this.name,
      required this.fcmToken,
      required this.creditInfo,
      required this.userWaitingStoreInfo,
      required this.userOrderingStoreInfo,
      required this.userLocationInfo});
}

class CreditInfo {}

class UserLocationInfo {
  final bool isPermissionGranted; // 위치 권한 상태
  final LocationInfo? locationInfo;

  UserLocationInfo({
    required this.isPermissionGranted,
    required this.locationInfo,
  });

  // 권한이 거부되었을 때 사용할 팩토리 생성자
  UserLocationInfo.permissionDenied()
      : isPermissionGranted = false,
        locationInfo = null;

  // 권한은 있으나 위치를 받아오지 못했을 때 사용할 팩토리 생성자
  UserLocationInfo.cannotFindUserLocation()
      : isPermissionGranted = true,
        locationInfo = null;
}

// App State로 사용할 "나의 대기정보"의 구성 멤버를 정의해준다
class UserWaitingStoreInfo {
  final StoreDetailInfo storeInfo;
  final int waitingNumber;

  final UserSimpleInfo userSimpleInfo;

  UserWaitingStoreInfo({
    required this.storeInfo,
    required this.waitingNumber,
    required this.userSimpleInfo,
  });
}

class UserOrderingStoreInfo {
  final int storeCode;
  final TableInfo tableInfo;

  UserOrderingStoreInfo({
    required this.storeCode,
    required this.tableInfo,
  });
}

class UserSimpleInfo {
  final String name;
  final String phoneNumber;
  final int numberOfUs;

  UserSimpleInfo({
    required this.name,
    required this.phoneNumber,
    required this.numberOfUs,
  });

  // JSON에서 Dart 객체 생성자
  factory UserSimpleInfo.fromJson(Map<String, dynamic> json) {
    return UserSimpleInfo(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      numberOfUs: json['numberOfUs'],
    );
  }
}
