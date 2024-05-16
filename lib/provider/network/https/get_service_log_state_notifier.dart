import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/menu_info_model.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
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
    print("ServiceLogResponse.fromJson");
    final status = json['status'];

    print("status: $status");
    final userLogs = List<UserLogs>.from(
        json['userLogs'].map((log) => UserLogs.fromJson(log)));
    print("userLogs: $userLogs");
    return ServiceLogResponse(
      status: json['status'],
      userLogs: List<UserLogs>.from(
          json['userLogs'].map((log) => UserLogs.fromJson(log))),
    );
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
    print("UserLogs.fromJson");
    final userPhoneNumber = json['userPhoneNumber'];
    print("userPhoneNumber: $userPhoneNumber");
    final historyNum = json['historyNum'];
    print("historyNum: $historyNum");
    final String status = json['status'];
    print("status: $status");
    final StoreWaitingStatus waitingStatus;
    DateTime? calledTimeOutDateTime;

    final statusChangeTime = DateTime.parse(json['statusChangeTime']);
    print("statusChangeTime: $statusChangeTime");

    if (status.contains(StoreWaitingStatus.CALLED.toEn())) {
      print("status.contains(StoreWaitingStatus.CALLED.toEn())");
      waitingStatus = StoreWaitingStatus.CALLED;
      print("waitingStatus: ${waitingStatus.toEn()}");

      // "called : {몇분}" 형식에서 {몇분}을 추출
      final calledTimeOutString =
          status.replaceFirst('${StoreWaitingStatus.CALLED.toEn()} : ', '');
      print("calledTimeOutString: $calledTimeOutString");

      // {몇분}을 DateTime 객체의 minute으로 변환
      final calledTimeOutMinutes = int.parse(calledTimeOutString);
      calledTimeOutDateTime =
          statusChangeTime.add(Duration(minutes: calledTimeOutMinutes));
      print("calledTimeOutDateTime: $calledTimeOutDateTime");
    } else {
      print("status.contains(StoreWaitingStatus.CALLED.toEn()) else");
      waitingStatus = StoreWaitingStatusExtension.fromString(status);
      print("waitingStatus: ${waitingStatus.toEn()}");
      calledTimeOutDateTime = null;
      print("calledTimeOutDateTime: $calledTimeOutDateTime");
    }

    print("status: ${waitingStatus.toKr()}");
    print("calledTimeOut: $calledTimeOutDateTime");

    final makeWaitingTime = DateTime.parse(json['makeWaitingTime']);
    print("makeWaitingTime: $makeWaitingTime");
    final storeCode = json['storeCode'];
    print("storeCode: $storeCode");
    final paidMoney = json['paidMoney'];
    print("paidMoney: $paidMoney");
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
      print("fetchStoreServiceLog");
      print("userPhoneNumber: $userPhoneNumber");

      final body = {
        'userPhoneNumber': userPhoneNumber,
      };

      final jsonBody = json.encode(body);
      final response = await HttpsService.postRequest('/log', jsonBody);

      if (response.statusCode == 200) {
        print("Log is fetched successfully!!!!!!!!!!!!!");
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        print('jsonBody: $jsonBody');
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
          return state;
        }
        // 로그가 있을 때
        else {
          final result = ServiceLogResponse.fromJson(jsonBody);
          state = result;
          print("state: $state");

          // 연결성 보장을 위한 Websocket Provider들 재설정
          if (result.userLogs.isNotEmpty) {
            // 마지막 로그의 정보로 Websocket Provider 재설정
            reconnectWebsocketProvider(result.userLogs.last);
          } else {
            print("로그 비어있음. storeWaitingRequestNotifierProvider 초기화");
            ref
                .read(storeWaitingRequestNotifierProvider.notifier)
                .clearWaitingRequestList();
          }

          return result;
        }
      } else {
        print("Log is not fetched!!!!!!!!!!!!!");
        state = ServiceLogResponse(
            status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
            userLogs: []);
        throw Exception('Failed to fetch Service Log');
      }
    } catch (error) {
      print("Log Fetch Error : $error");
      state = ServiceLogResponse(
          status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
          userLogs: []);
      throw Exception('Failed to fetch Service Log');
    }
  }

  void reconnectWebsocketProvider(UserLogs lastUserLog) {
    print("reconnectWebsocketProvider");
    ref.read(stompClientStateNotifierProvider.notifier).configureClient();
    ref.read(stompClientStateNotifierProvider.notifier).state?.activate();

    if (lastUserLog.status == StoreWaitingStatus.WAITING) {
      // 현재 웨이팅 중이었다면

      // waitingCancel 재구독
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingCall 재구독
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(lastUserLog.storeCode, lastUserLog.waiting);
    } else if (lastUserLog.status == StoreWaitingStatus.CALLED) {
      // 웨이팅 중인데 호출되었다면

      // waitingCancel 재구독
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingTimer 재설정
      ref
          .read(waitingUserCallTimeListProvider.notifier)
          .setUserCallTime(lastUserLog.calledTimeOut ?? DateTime.now());
    } else if (lastUserLog.status == StoreWaitingStatus.USER_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.STORE_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.ENTERD) {
      // user나 store가 이미 취소했거나 입장했다면

      // 모든 웨이팅 관련 Provider 초기화
      // waitingCancel 삭제
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      // waitingCall 삭제
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
    }
  }
}
