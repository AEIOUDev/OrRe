import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/debug_services.dart';
import 'package:orre/services/notifications_services.dart';
import 'package:stomp_dart_client/stomp.dart';

import '../../../model/store_service_log_model.dart';
import '../https/get_service_log_state_notifier.dart';

final cancelDialogStatus = StateProvider<int?>((ref) => null);

final isWaitingNow = StateProvider<bool>((ref) {
  return false;
});

final waitingStatus =
    StateNotifierProvider<UserWaitingStatusStateNotifier, StoreWaitingStatus?>(
        (ref) => UserWaitingStatusStateNotifier(ref));

class UserWaitingStatusStateNotifier
    extends StateNotifier<StoreWaitingStatus?> {
  final Ref ref;
  UserWaitingStatusStateNotifier(this.ref) : super(null);

  void setWaitingStatus(StoreWaitingStatus status) {
    // 웨이팅 상태를 변경하고 알림을 표시합니다.
    printd("setWaitingStatus : $status");
    // 이전 상태와 동일한 경우 알림을 표시하지 않습니다.
    if (state == status) {
      return;
    }
    state = status;
    switch (status) {
      case StoreWaitingStatus.USER_CANCELED:
        NotificationService.showNotification(NotificationType.waitingCancel);
        break;
      case StoreWaitingStatus.WAITING:
        NotificationService.showNotification(NotificationType.waitingSuccess);
        break;
      case StoreWaitingStatus.ETC:
      case StoreWaitingStatus.ENTERD:
      case StoreWaitingStatus.STORE_CLOSED:
      case StoreWaitingStatus.STORE_CANCELED:
        break;
      default:
    }
  }
}

final storeWaitingRequestNotifierProvider =
    StateNotifierProvider<StoreWaitingRequestNotifier, StoreWaitingRequest?>(
        (ref) {
  return StoreWaitingRequestNotifier(ref);
});

class StoreWaitingRequestNotifier extends StateNotifier<StoreWaitingRequest?> {
  StompClient? _client;
  late Ref ref;
  final _storage = FlutterSecureStorage();

  // Map<int, Completer> completers = {};

  Map<dynamic, dynamic> _subscribeRequest = {};
  int storeCodeForRequest = -1;

  Map<dynamic, dynamic> _subscribeCancel = {};
  int storeCodeForCancel = -1;

  StoreWaitingRequestNotifier(this.ref) : super(null) {
    printd("StoreWaitingRequest : constructor");
  }

  bool isClientConnected() {
    return _client?.connected ?? false;
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    printd("StoreWaitingRequest : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    // loadWaitingRequestList();
  }

  Future<APIResponseStatus> startSubscribe(
      int storeCode, String userPhoneNumber, int personNumber) async {
    Completer<APIResponseStatus> completer = Completer<APIResponseStatus>();
    printd("startSubscribe : $storeCode, $userPhoneNumber, $personNumber");
    if (_client != null) {
      if (state != null) {
        printd("state is not null");
        unSubscribe(storeCode);
      }
      await subscribeToStoreWaitingRequest(
              storeCode, userPhoneNumber, personNumber)
          .then((value) {
        if (value == APIResponseStatus.success) {
          printd("WaitingRequest waitingSubscribeComplete : Success");
          completer.complete(value);
          saveWaitingRequestList();
          subscribeToStoreWaitingCancelRequest(storeCode, userPhoneNumber);
        } else {
          printd("WaitingRequest waitingSubscribeComplete : Fail 2");
          completer.complete(value);
        }
      });
    } else {
      printd("WaitingRequest waitingSubscribeComplete : Fail 3");
      completer.complete(APIResponseStatus.waitingJoinFailure);
    }
    return completer.future;
  }

  Future<APIResponseStatus> subscribeToStoreWaitingRequest(
    int storeCode,
    String userPhoneNumber,
    int personNumber,
  ) async {
    printd(
        "subscribeToStoreWaitingRequest : $storeCode, $userPhoneNumber, $personNumber");
    Completer<APIResponseStatus> completer = Completer<APIResponseStatus>();

    // 구독이 이미 설정되어 있지 않은 경우에만 요청을 보냅니다.
    if (_subscribeRequest[storeCode.toString()] == null) {
      // 구독 설정
      _subscribeRequest[storeCode.toString()] = _client?.subscribe(
        destination:
            '${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGREQUEST_SUBSCRIBE')}$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            printd("subscribeToStoreWaitingRequest : ${frame.body}");
            try {
              var decodedBody = json.decode(frame.body!);
              var firstResult = StoreWaitingRequest.fromJson(decodedBody);
              printd(
                  "subscribeToStoreWaitingRequest firstResult : $firstResult");
              ref
                  .read(serviceLogProvider.notifier)
                  .fetchStoreServiceLog(userPhoneNumber);
              if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
                waitingAddProcess(firstResult);
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.WAITING); // 웨이팅 상태로 변경
                completer.complete(APIResponseStatus.success);
              } else if (APIResponseStatus.waitingAlreadyJoin
                  .isEqualTo(decodedBody['status'])) {
                printd("이미 웨이팅 중입니다.");
                waitingAddProcess(firstResult);
                completer.complete(APIResponseStatus.waitingAlreadyJoin);
              } else {
                printd("웨이팅 실패!! : 가게가 웨이팅을 받지 않습니다.");
                completer.complete(APIResponseStatus.waitingJoinFailure);
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(APIResponseStatus.waitingJoinFailure);
              }
            }
          } else {
            completer.complete(APIResponseStatus.waitingJoinFailure);
          }
        },
      );

      // 요청을 보냅니다. 이 로직은 구독 설정과 동시에 한 번만 실행됩니다.
      sendWaitingRequest(storeCode, userPhoneNumber, personNumber);
    } else {
      printd("Already subscribed to this storeCode: $storeCode");
      // 이미 구독된 상태라면, 기존 구독을 유지하고 새 요청을 보내지 않습니다.
      if (!completer.isCompleted) {
        completer.complete(APIResponseStatus.waitingAlreadyJoin);
      }
    }

    return completer.future;
  }

  Future<bool> subscribeToStoreWaitingCancelRequest(
    int storeCode,
    String userPhoneNumber,
  ) async {
    Completer<bool> completer = Completer<bool>();
    if (_subscribeCancel[storeCode.toString()] == null) {
      ref.read(isWaitingNow.notifier).state = true;
      printd(
          "subscribeToStoreWaitingCancelRequest : $storeCode, $userPhoneNumber");
      _subscribeCancel[storeCode.toString()] = _client?.subscribe(
        destination:
            '${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGCANCELREQUEST_SUBSCRIBE')}$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            printd("subscribeToStoreWaitingCancelRequest : ${frame.body}");
            try {
              var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
              printd(
                  "decodedBody!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! : $decodedBody");
              ref
                  .read(serviceLogProvider.notifier)
                  .fetchStoreServiceLog(userPhoneNumber);
              if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
                printd("웨이팅 취소 성공!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancelDialogStatus.notifier).state = 200;
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.USER_CANCELED);
                completer.complete(true);
              } else if (APIResponseStatus.waitingCancelByStore
                  .isEqualTo(decodedBody['status'])) {
                printd("가게에서 취소!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancelDialogStatus.notifier).state = 1103;
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.STORE_CANCELED);
                completer.complete(true);
              } else if (APIResponseStatus.waitingEnteringSuccess
                  .isEqualTo(decodedBody['status'])) {
                printd("입장 성공!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancelDialogStatus.notifier).state = 1104;
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.ENTERD);
                completer.complete(true);
              } else if (APIResponseStatus.waitingCancelByStoreClosed
                  .isEqualTo(decodedBody['status'])) {
                printd("가게 영업 마감!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancelDialogStatus.notifier).state = 1106;
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.STORE_CLOSED);
                completer.complete(true);
              } else {
                printd("웨이팅 취소 실패!!");
                waitingCancelProcess(false, storeCode, userPhoneNumber);
                ref.read(cancelDialogStatus.notifier).state = 1102;
                ref
                    .read(waitingStatus.notifier)
                    .setWaitingStatus(StoreWaitingStatus.ETC);
                completer.complete(false);
              }
            } catch (e) {
              printd("Error decoding data: $e");
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          }
        },
      );
    }
    return completer.future;
  }

  // 웨이팅 요청을 서버로 전송하는 메소드
  void sendWaitingRequest(
      int storeCode, String userPhoneNumber, int personNumber) {
    printd("storeCodeForRequest : $storeCodeForRequest");
    if (storeCodeForRequest == -1) {
      printd(
          "sendWaitingRequest : {$storeCode}, {$userPhoneNumber}, {$personNumber}");
      _client?.send(
        destination:
            '${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGREQUEST_REQUEST')}$storeCode/$userPhoneNumber',
        body: json.encode({
          "userPhoneNumber": userPhoneNumber,
          "storeCode": storeCode,
          "personNumber": personNumber,
        }),
      );
      storeCodeForRequest = storeCode;
    } else {
      printd("Already sendWaitingRequest : {$storeCode}, {$userPhoneNumber}");
    }
  }

  void sendWaitingCancelRequest(int storeCode, String userPhoneNumber) {
    printd("storeCodeForCancel : $storeCodeForCancel");
    if (storeCodeForCancel == -1) {
      printd("sendWaitingCancelRequest : {$storeCode}, {$userPhoneNumber}");
      _client?.send(
        destination:
            "${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGCANCELREQUEST_REQUEST')}$storeCode/$userPhoneNumber",
        body: json.encode({
          "userPhoneNumber": userPhoneNumber,
          "storeCode": storeCode,
        }),
      );
      storeCodeForCancel = storeCode;
    } else {
      printd(
          "Already sendWaitingCancelRequest : {$storeCode}, {$userPhoneNumber}");
    }
  }

  void waitingAddProcess(StoreWaitingRequest result) {
    if (APIResponseStatus.success.isEqualTo(result.status)) {
      state = result;

      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(result.token.storeCode, result.token.waiting);
      var unsubscribeFunction = _subscribeRequest[result.token.storeCode];
      if (unsubscribeFunction != null) {
        unsubscribeFunction(unsubscribeHeaders: {}); // 구독 해제 함수 호출
        _subscribeRequest[result.token.storeCode] = null;
        saveWaitingRequestList();
      } else {
        printd("unsubscribeFunction is null");
      }
    } else {
      printd(result.token);
    }
  }

  void waitingCancelProcess(bool result, int storeCode, String phoneNumber) {
    printd("waitingCancelProcess : $result, $storeCode, $phoneNumber");
    if (result) {
      printd("waitingCancelProcessSuccess : $result, $storeCode, $phoneNumber");
      unSubscribe(storeCode);
      ref.read(waitingUserCallTimeListProvider.notifier).deleteTimer();
      state = null;
      storeCodeForCancel = -1;
    } else {
      printd(result);
    }
  }

  void unSubscribe(int storeCode) {
    printd("cancel waiting/make/$storeCode");
    var unsubscribeFunction = _subscribeRequest[storeCode.toString()];
    if (unsubscribeFunction != null) {
      // Map<String, String> 타입을 명시하여 타입 에러를 해결
      unsubscribeFunction(unsubscribeHeaders: <String, String>{});
      _subscribeRequest[storeCode.toString()] = null; // 올바른 null 할당
      _subscribeRequest.remove(storeCode.toString()); // 구독 해제 함수
      storeCodeForRequest = -1;
    }

    printd("cancel waiting/cancel/$storeCode");
    var unsubscribeFunctionCancel = _subscribeCancel[storeCode.toString()];
    if (unsubscribeFunctionCancel != null) {
      // Map<String, String> 타입을 명시하여 타입 에러를 해결
      unsubscribeFunctionCancel(unsubscribeHeaders: <String, String>{});
      _subscribeCancel[storeCode.toString()] = null; // 올바른 null 할당
      _subscribeCancel.remove(storeCode.toString()); // 구독 해제 함수 삭제
      storeCodeForCancel = -1;
    }

    state = null;
    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    final json_data_status = jsonEncode(state);
    printd("saveWaitingRequest : $json_data_status");
    await _storage.write(key: 'waitingStatus', value: json_data_status);
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadWaitingRequestList() async {
    printd("loadWaitingRequest");
    final json_data_status = await _storage.read(key: 'waitingStatus');
    printd("loadWaitingRequest : $json_data_status");

    if (json_data_status != null) {
      printd("json_data_status : $json_data_status");
      // JSON 데이터가 존재하면 상태를 업데이트하고 구독을 시작합니다.
      state = StoreWaitingRequest.fromJson(jsonDecode(json_data_status));
      // 안전을 위해 state가 정상적으로 설정되었는지 다시 확인
      if (state != StoreWaitingRequest.nullValue() &&
          state?.token.storeCode != -1) {
        if (state != null) {
          printd("state is not null");
          if (state?.token != StoreWaitingRequest.nullValue().token) {
            printd("state.token is not null");

            StoreWaitingRequestDetail token =
                state?.token as StoreWaitingRequestDetail;

            subscribeToStoreWaitingCancelRequest(
                token.storeCode, token.phoneNumber);
          } else {
            printd("state.token is null");
          }
        }
      } else {
        printd("state is null");
        state = null;
      }
    } else {
      // JSON 데이터가 없을 때는 상태를 null로 설정하고 추가 작업을 수행하지 않습니다.
      printd("json_data_status is null");
      state = null;
    }
  }

  void clearWaitingRequestList() {
    printd("clearWaitingRequestList");
    if (state != null) {
      ref.read(isWaitingNow.notifier).state = false;

      StoreWaitingRequestDetail token =
          state?.token as StoreWaitingRequestDetail;
      unSubscribe(token.storeCode);
    }
  }

  void reconnect() {
    _client?.activate();
    printd("storeWaitingInfo reconnect");
    loadWaitingRequestList();
    if (state != null) {
      StoreWaitingRequest newState = state as StoreWaitingRequest;
      printd("reconnect : ${newState.token.storeCode}");
      subscribeToStoreWaitingCancelRequest(
          newState.token.storeCode, newState.token.phoneNumber);
    }
  }

  void repairStateByServiceLog(UserLogs userLogs) {
    String status = userLogs.status.toCode();
    printd("repairStateByServiceLog status : $status");

    if (StoreWaitingStatus.USER_CANCELED == userLogs.status ||
        StoreWaitingStatus.STORE_CANCELED == userLogs.status ||
        StoreWaitingStatus.ENTERD == userLogs.status ||
        StoreWaitingStatus.STORE_CLOSED == userLogs.status) {
      // 현재 웨이팅 중이 아님
      state = null;
      printd("repairStateByServiceLog state is null");
    } else {
      // 현재 웨이팅 중
      StoreWaitingRequest newState = StoreWaitingRequest(
        status: status,
        token: StoreWaitingRequestDetail(
          storeCode: userLogs.storeCode,
          waiting: userLogs.waiting,
          status: -1, // TODO: 서버에서 상태값을 받아오는 로직이 필요
          phoneNumber: userLogs.userPhoneNumber,
          personNumber: userLogs.personNumber,
        ),
      );
      state = newState;
      printd(
          "repairStateByServiceLog state is not null : ${state?.token.waiting}");
    }
  }
}
