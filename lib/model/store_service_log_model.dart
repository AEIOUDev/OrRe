// ignore_for_file: constant_identifier_names

import 'package:orre/model/menu_info_model.dart';

import '../services/debug_services.dart';

enum StoreWaitingStatus {
  WAITING,
  USER_CANCELED,
  STORE_CANCELED,
  STORE_CLOSED,
  CALLED,
  ENTERD,
  ETC,
}

extension StoreWaitingStatusExtension on StoreWaitingStatus {
  String toEn() {
    switch (this) {
      case StoreWaitingStatus.WAITING:
        return 'waiting';
      case StoreWaitingStatus.USER_CANCELED:
        return 'user canceled';
      case StoreWaitingStatus.STORE_CANCELED:
        return 'store canceled';
      case StoreWaitingStatus.STORE_CLOSED:
        return 'store closed';
      case StoreWaitingStatus.CALLED:
        return 'called';
      case StoreWaitingStatus.ENTERD:
        return 'enterd';
      default:
        return 'etc';
    }
  }

  String toKr() {
    switch (this) {
      case StoreWaitingStatus.WAITING:
        return '대기중';
      case StoreWaitingStatus.USER_CANCELED:
        return '사용자 취소';
      case StoreWaitingStatus.STORE_CANCELED:
        return '가게 취소';
      case StoreWaitingStatus.STORE_CLOSED:
        return '가게 영업 마감';
      case StoreWaitingStatus.CALLED:
        return '호출됨';
      case StoreWaitingStatus.ENTERD:
        return '입장';
      default:
        return '기타';
    }
  }

  String toCode() {
    switch (this) {
      case StoreWaitingStatus.WAITING:
      case StoreWaitingStatus.USER_CANCELED:
      case StoreWaitingStatus.CALLED:
        return '200';
      case StoreWaitingStatus.STORE_CANCELED:
        return '1103';
      case StoreWaitingStatus.ENTERD:
        return '1105';
      case StoreWaitingStatus.STORE_CLOSED:
        return '1106';
      default:
        return 'etc';
    }
  }

  int toInt() {
    switch (this) {
      case StoreWaitingStatus.WAITING:
      case StoreWaitingStatus.USER_CANCELED:
      case StoreWaitingStatus.CALLED:
        return 200;
      case StoreWaitingStatus.STORE_CANCELED:
        return 1103;
      case StoreWaitingStatus.ENTERD:
        return 1105;
      case StoreWaitingStatus.STORE_CLOSED:
        return 1106;
      default:
        return 0;
    }
  }

  static StoreWaitingStatus fromString(String status) {
    switch (status) {
      case 'waiting':
        return StoreWaitingStatus.WAITING;
      case 'user canceled':
        return StoreWaitingStatus.USER_CANCELED;
      case 'store canceled':
        return StoreWaitingStatus.STORE_CANCELED;
      case 'called':
        return StoreWaitingStatus.CALLED;
      case 'entered':
        return StoreWaitingStatus.ENTERD;
      case 'store closed':
        return StoreWaitingStatus.STORE_CLOSED;
      default:
        return StoreWaitingStatus.ETC;
    }
  }
}

class ServiceLogResponse {
  final String status;
  final List<UserLogs> userLogs;

  ServiceLogResponse({
    required this.status,
    required this.userLogs,
  });

  ServiceLogResponse copyWith({
    String? status,
    List<UserLogs>? userLogs,
  }) {
    return ServiceLogResponse(
      status: status ?? this.status,
      userLogs: userLogs ?? this.userLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'userLogs': userLogs.map((log) => log.toJson()).toList(),
    };
  }

  static ServiceLogResponse fromJson(Map<String, dynamic> json) {
    // printd("ServiceLogResponse.fromJson");
    final status = json['status'];

    // printd("status: $status");
    final userLogs = List<UserLogs>.from(
        json['userLogs'].map((log) => UserLogs.fromJson(log)));
    // printd("userLogs: $userLogs");
    return ServiceLogResponse(status: status, userLogs: userLogs);
  }
}

class UserLogs {
  final String userPhoneNumber;
  final int historyNum;
  final StoreWaitingStatus status;
  final DateTime? makeWaitingTime;
  final DateTime? calledTimeOut;
  final int storeCode;
  final DateTime? statusChangeTime;
  final int paidMoney;
  final int waiting;
  final int personNumber;
  final List<MenuInfo> orderedMenu;

  UserLogs({
    required this.userPhoneNumber,
    required this.historyNum,
    required this.status,
    required this.makeWaitingTime,
    required this.calledTimeOut,
    required this.storeCode,
    required this.statusChangeTime,
    required this.paidMoney,
    required this.waiting,
    required this.personNumber,
    required this.orderedMenu,
  });

  Map<String, dynamic> toJson() {
    return {
      'userPhoneNumber': userPhoneNumber,
      'historyNum': historyNum,
      'status': status.toEn(),
      'makeWaitingTime': makeWaitingTime.toString(),
      'calledTimeOut': calledTimeOut.toString(),
      'storeCode': storeCode,
      'statusChangeTime': statusChangeTime.toString(),
      'paidMoney': paidMoney,
      'waiting': waiting,
      'personNumber': personNumber,
      'orderedMenu': orderedMenu.map((menu) => menu.toJson()).toList(),
    };
  }

  static UserLogs fromJson(Map<String, dynamic> json) {
    // printd("UserLogs.fromJson");
    final userPhoneNumber = json['userPhoneNumber'];
    // printd("userPhoneNumber: $userPhoneNumber");
    final historyNum = json['historyNum'];
    // printd("historyNum: $historyNum");
    final String status = json['status'];
    // printd("status: $status");
    final StoreWaitingStatus waitingStatus;
    DateTime? calledTimeOutDateTime;

    final statusChangeTime = DateTime.parse(json['statusChangeTime']);
    // printd("statusChangeTime: $statusChangeTime");

    if (status.contains(StoreWaitingStatus.CALLED.toEn())) {
      // printd("status.contains(StoreWaitingStatus.CALLED.toEn())");
      waitingStatus = StoreWaitingStatus.CALLED;
      // printd("waitingStatus: ${waitingStatus.toEn()}");

      // "called : {몇분}" 형식에서 {몇분}을 추출
      final calledTimeOutString =
          status.replaceFirst('${StoreWaitingStatus.CALLED.toEn()} : ', '');
      // printd("calledTimeOutString: $calledTimeOutString");

      printd("statusChangeTime: $statusChangeTime");

      // {몇분}을 DateTime 객체의 minute으로 변환
      final calledTimeOutMinutes = int.parse(calledTimeOutString);
      calledTimeOutDateTime =
          statusChangeTime.add(Duration(minutes: calledTimeOutMinutes));
      // printd("calledTimeOutDateTime: $calledTimeOutDateTime");
    } else {
      // printd("status.contains(StoreWaitingStatus.CALLED.toEn()) else");
      waitingStatus = StoreWaitingStatusExtension.fromString(status);
      // printd("waitingStatus: ${waitingStatus.toEn()}");
      calledTimeOutDateTime = null;
      // printd("calledTimeOutDateTime: $calledTimeOutDateTime");
    }

    // printd("status: ${waitingStatus.toKr()}");
    // printd("calledTimeOut: $calledTimeOutDateTime");

    final makeWaitingTime = DateTime.parse(json['makeWaitingTime']);
    // printd("makeWaitingTime: $makeWaitingTime");
    final storeCode = json['storeCode'];
    // printd("storeCode: $storeCode");
    final paidMoney = json['paidMoney'];
    // printd("paidMoney: $paidMoney");
    final orderedMenu = json['orderedMenu'];
    List<MenuInfo> menuConvert = [];
    if (orderedMenu == null || orderedMenu == "") {
      menuConvert = [];
    } else {
      menuConvert = List<MenuInfo>.from(
          json['orderedMenu'].map((menu) => MenuInfo.fromJson(menu)));
    }

    return UserLogs(
      userPhoneNumber: userPhoneNumber,
      historyNum: historyNum,
      status: waitingStatus,
      makeWaitingTime: makeWaitingTime,
      calledTimeOut: calledTimeOutDateTime,
      storeCode: storeCode,
      statusChangeTime: statusChangeTime,
      waiting: json['waiting'],
      personNumber: json['personNumber'],
      paidMoney: paidMoney,
      orderedMenu: menuConvert,
    );
  }
}
