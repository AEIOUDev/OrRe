// 요청자의 정보를 담는 모델
import 'store_info_model.dart';

class UserInfo {
  final String phoneNumber;
  final String password;
  final String name;
  final String fcmToken;

  UserInfo({
    required this.phoneNumber,
    required this.password,
    required this.name,
    required this.fcmToken,
  });

  UserInfo copyWith({
    String? phoneNumber,
    String? password,
    String? name,
    String? fcmToken,
  }) {
    return UserInfo(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      name: name ?? this.name,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  static UserInfo nullValue() {
    return UserInfo(
      phoneNumber: '',
      password: '',
      name: '',
      fcmToken: '',
    );
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserInfo &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.name == name &&
        other.fcmToken == fcmToken;
  }
}

class SignUpInfo {
  final String phoneNumber;
  final String password;
  final String nickname;
  final String authCode;

  SignUpInfo({
    required this.phoneNumber,
    required this.password,
    required this.nickname,
    required this.authCode,
  });
}

class SignInInfo {
  final String phoneNumber;
  final String password;

  SignInInfo({
    required this.phoneNumber,
    required this.password,
  });
}

class CreditInfo {}

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
      phoneNumber: json['userPhoneNumber'],
      numberOfUs: json['numberOfUs'],
    );
  }
}
