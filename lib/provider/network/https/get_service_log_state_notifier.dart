import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/debug.services.dart';
import 'package:orre/model/menu_info_model.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';

enum StoreWaitingStatus {
  WAITING,
  USER_CANCELED,
  STORE_CANCELED,
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

final serviceLogProvider =
    StateNotifierProvider<ServiceLogStateNotifier, ServiceLogResponse>((ref) {
  return ServiceLogStateNotifier(ref);
});

class ServiceLogStateNotifier extends StateNotifier<ServiceLogResponse> {
  late Ref ref;
  ServiceLogStateNotifier(this.ref)
      : super(ServiceLogResponse(status: '', userLogs: []));

  Future<ServiceLogResponse> fetchStoreServiceLog(
      String userPhoneNumber) async {
    try {
      // printd("fetchStoreServiceLog");
      // printd("userPhoneNumber: $userPhoneNumber");

      final body = {
        'userPhoneNumber': userPhoneNumber,
      };

      final jsonBody = json.encode(body);
      final response = await HttpsService.postRequest('/log', jsonBody);

      if (response.statusCode == 200) {
        printd("Log is fetched successfully!!!!!!!!!!!!!");
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        // printd('jsonBody: $jsonBody');
        // 로그가 없을 때
        if (jsonBody['status'] == APIResponseStatus.serviceLogEmpty.toCode()) {
          state = ServiceLogResponse(
              status: APIResponseStatus.serviceLogEmpty.toCode(), userLogs: []);
          return state;
        }
        // 해당하는 전화번호가 없을 때
        else if (jsonBody['status'] ==
            APIResponseStatus.serviceLogPhoneNumberFailure.toCode()) {
          state = ServiceLogResponse(
              status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
              userLogs: []);
          printd("해당하는 전화번호가 없음");
          return state;
        }
        // 로그가 있을 때
        else {
          printd("로그가 있음");
          final result = ServiceLogResponse.fromJson(jsonBody);
          state = result;
          // printd("state: $state");

          return result;
        }
      } else {
        printd("Log is not fetched!!!!!!!!!!!!!");
        state = ServiceLogResponse(
            status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
            userLogs: []);
        throw Exception('Failed to fetch Service Log');
      }
    } catch (error) {
      printd("Log Fetch Error : $error");
      state = ServiceLogResponse(
          status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
          userLogs: []);
      throw Exception('Failed to fetch Service Log');
    }
  }

  void reconnectWebsocketProvider(UserLogs lastUserLog) {
    printd("reconnectWebsocketProvider");

    if (lastUserLog.status == StoreWaitingStatus.WAITING) {
      printd("현재 웨이팅 중! : ${lastUserLog.status}");
      // 현재 웨이팅 중이었다면

      // waitingCancel 재구독
      printd("이전 웨이팅 관련 구독 해제");
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();

      printd("웨이팅 취소 구독 시작");
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingCall 재구독
      printd("유저 호출 구독 해제");
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();

      printd("유저 호출 구독 시작");
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(lastUserLog.storeCode, lastUserLog.waiting);

      // serviceLog를 기반으로 waiting state를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
    } else if (lastUserLog.status == StoreWaitingStatus.CALLED) {
      // 웨이팅 중인데 호출되었다면
      printd("현재 호출 중! : ${lastUserLog.status}");

      // waitingCancel 재구독
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingTimer 재설정
      printd("유저 호출 시간 재설정");
      // printd("lastUserLog.calledTimeOut: ${lastUserLog.calledTimeOut}");
      final userCallTime = lastUserLog.calledTimeOut ?? DateTime.now();
      ref
          .read(waitingUserCallTimeListProvider.notifier)
          .setUserCallTime(userCallTime);

      // serviceLog를 기반으로 waiting state 및 UserCall를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .repairUserCallStateByServiceLog(lastUserLog);
    } else if (lastUserLog.status == StoreWaitingStatus.USER_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.STORE_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.ENTERD) {
      // user나 store가 이미 취소했거나 입장했다면
      printd("취소 됨! : ${lastUserLog.status}");

      // 모든 웨이팅 관련 Provider 초기화
      // waitingCancel 삭제
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      // waitingCall 삭제
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();

      // serviceLog를 기반으로 waiting state를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
    }
  }
}
