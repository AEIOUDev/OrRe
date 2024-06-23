// 요청자의 정보를 담는 모델
import 'package:equatable/equatable.dart';

import 'store_info_model.dart';

class UserInfo extends Equatable {
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

  @override
  List<Object?> get props => [phoneNumber, password, name, fcmToken];
}

class SignUpInfo extends Equatable {
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

  @override
  List<Object?> get props => [phoneNumber, password, nickname, authCode];
}

class SignInInfo extends Equatable {
  final String phoneNumber;
  final String password;

  SignInInfo({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

class CreditInfo extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

// App State로 사용할 "나의 대기정보"의 구성 멤버를 정의해준다
class UserWaitingStoreInfo extends Equatable {
  final StoreDetailInfo storeInfo;
  final int waitingNumber;

  final UserSimpleInfo userSimpleInfo;

  UserWaitingStoreInfo({
    required this.storeInfo,
    required this.waitingNumber,
    required this.userSimpleInfo,
  });

  @override
  List<Object?> get props => [storeInfo, waitingNumber, userSimpleInfo];
}

class UserOrderingStoreInfo extends Equatable {
  final int storeCode;
  final TableInfo tableInfo;

  UserOrderingStoreInfo({
    required this.storeCode,
    required this.tableInfo,
  });

  @override
  List<Object?> get props => [storeCode, tableInfo];
}

class UserSimpleInfo extends Equatable {
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

  // Dart 객체에서 JSON 생성자
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userPhoneNumber': phoneNumber,
      'numberOfUs': numberOfUs,
    };
  }

  @override
  List<Object?> get props => [name, phoneNumber, numberOfUs];
}
