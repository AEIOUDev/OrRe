import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cancleDialogStatus = StateProvider<int?>((ref) => null);

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

  Map<dynamic, dynamic> _subscribeCancle = {};
  int storeCodeForCancle = -1;

  StoreWaitingRequestNotifier(this.ref) : super(null) {
    print("StoreWaitingRequest : constructor");
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingRequest : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    loadWaitingRequestList();
  }

  Future<bool> startSubscribe(
      int storeCode, String userPhoneNumber, int personNumber) async {
    Completer<bool> completer = Completer<bool>();
    print("startSubscribe : $storeCode, $userPhoneNumber, $personNumber");
    if (_client != null) {
      if (state != null) {
        print("state is not null");
        unSubscribe(state!.token.storeCode);
      }
      var request = await subscribeToStoreWaitingRequest(
              storeCode, userPhoneNumber, personNumber)
          .then((value) {
        if (value) {
          print("WaitingRequest waitingSubscribeComplete : Success");
          completer.complete(true);
          saveWaitingRequestList();
          subscribeToStoreWaitingCancleRequest(storeCode, userPhoneNumber);
          // if (cancle) {
          //   print("WaitingRequest waitingCancleSubcribeComplete : Success");
          //   completer.complete(true);
          // } else {
          //   // print("WaitingRequest waitingCancleSubcribeComplete : Fail 1");
          //   // completer.complete(false);
          // }
        } else {
          print("WaitingRequest waitingSubscribeComplete : Fail 2");
          completer.complete(false);
        }
      });
    } else {
      print("WaitingRequest waitingSubscribeComplete : Fail 3");
      completer.complete(false);
    }
    return completer.future;
  }

  Future<bool> subscribeToStoreWaitingRequest(
    int storeCode,
    String userPhoneNumber,
    int personNumber,
  ) async {
    print(
        "subscribeToStoreWaitingRequest : $storeCode, $userPhoneNumber, $personNumber");
    Completer<bool> completer = Completer<bool>();

    // 구독이 이미 설정되어 있지 않은 경우에만 요청을 보냅니다.
    if (_subscribeRequest[storeCode.toString()] == null) {
      // 구독 설정
      _subscribeRequest[storeCode.toString()] = _client?.subscribe(
        destination: '/topic/user/waiting/make/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingRequest : ${frame.body}");
            try {
              var decodedBody = json.decode(frame.body!);
              if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
                var firstResult = StoreWaitingRequest.fromJson(decodedBody);
                waitingAddProcess(firstResult);
                completer.complete(true);
              } else {
                completer.complete(false);
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          } else {
            completer.complete(false);
          }
        },
      );

      // 요청을 보냅니다. 이 로직은 구독 설정과 동시에 한 번만 실행됩니다.
      sendWaitingRequest(storeCode, userPhoneNumber, personNumber);
    } else {
      print("Already subscribed to this storeCode: $storeCode");
      // 이미 구독된 상태라면, 기존 구독을 유지하고 새 요청을 보내지 않습니다.
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> subscribeToStoreWaitingCancleRequest(
    int storeCode,
    String userPhoneNumber,
  ) async {
    Completer<bool> completer = Completer<bool>();
    if (_subscribeCancle[storeCode.toString()] == null) {
      print(
          "subscribeToStoreWaitingCancleRequest : $storeCode, $userPhoneNumber");
      _subscribeCancle[storeCode.toString()] = _client?.subscribe(
        destination: '/topic/user/waiting/cancel/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingCancleRequest : ${frame.body}");
            try {
              var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
              print(
                  "decodedBody!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! : $decodedBody");
              if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
                print("웨이팅 취소 성공!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancleDialogStatus.notifier).state = 200;
                completer.complete(true);
              } else if (APIResponseStatus.waitingCancleByStore
                  .isEqualTo(decodedBody['status'])) {
                print("가게에서 취소!!");
                waitingCancelProcess(true, storeCode, userPhoneNumber);
                ref.read(cancleDialogStatus.notifier).state = 1103;
                completer.complete(false);
              } else {
                print("웨이팅 취소 실패!!");
                waitingCancelProcess(false, storeCode, userPhoneNumber);
                ref.read(cancleDialogStatus.notifier).state = 1102;
                completer.complete(false);
              }
            } catch (e) {
              print("Error decoding data: $e");
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
    print("storeCodeForRequest : $storeCodeForRequest");
    if (storeCodeForRequest == -1) {
      print(
          "sendWaitingRequest : {$storeCode}, {$userPhoneNumber}, {$personNumber}");
      _client?.send(
        destination: '/app/user/waiting/make/$storeCode/$userPhoneNumber',
        body: json.encode({
          "userPhoneNumber": userPhoneNumber,
          "storeCode": storeCode,
          "personNumber": personNumber,
        }),
      );
      storeCodeForRequest = storeCode;
    } else {
      print("Already sendWaitingRequest : {$storeCode}, {$userPhoneNumber}");
    }
  }

  void sendWaitingCancleRequest(int storeCode, String userPhoneNumber) {
    print("storeCodeForCancle : $storeCodeForCancle");
    if (storeCodeForCancle == -1) {
      print("sendWaitingCancleRequest : {$storeCode}, {$userPhoneNumber}");
      _client?.send(
        destination: '/app/user/waiting/cancel/$storeCode/$userPhoneNumber',
        body: json.encode({
          "userPhoneNumber": userPhoneNumber,
          "storeCode": storeCode,
        }),
      );
      storeCodeForCancle = storeCode;
    } else {
      print(
          "Already sendWaitingCancleRequest : {$storeCode}, {$userPhoneNumber}");
    }
  }

  void waitingAddProcess(StoreWaitingRequest result) {
    if (APIResponseStatus.success.isEqualTo(result.status)) {
      state = result;
      var unsubscribeFunction = _subscribeRequest[result.token.storeCode];
      if (unsubscribeFunction != null) {
        unsubscribeFunction(unsubscribeHeaders: {}); // 구독 해제 함수 호출
        _subscribeRequest[result.token.storeCode] = null;
        saveWaitingRequestList();
      } else {
        print("unsubscribeFunction is null");
      }
    } else {
      print(result.token);
    }
  }

  void waitingCancelProcess(bool result, int storeCode, String phoneNumber) {
    print("waitingCancelProcess : $result, $storeCode, $phoneNumber");
    if (result) {
      print("waitingCancelProcessSuccess : $result, $storeCode, $phoneNumber");
      unSubscribe(storeCode);
      ref.read(waitingUserCallTimeListProvider.notifier).deleteTimer();
      state = null;
      storeCodeForCancle = -1;
    } else {
      print(result);
    }
  }

  void unSubscribe(int storeCode) {
    print("cancel waiting/make/$storeCode");
    var unsubscribeFunction = _subscribeRequest[storeCode.toString()];
    if (unsubscribeFunction != null) {
      // Map<String, String> 타입을 명시하여 타입 에러를 해결
      unsubscribeFunction(unsubscribeHeaders: <String, String>{});
      _subscribeRequest[storeCode.toString()] = null; // 올바른 null 할당
      _subscribeRequest.remove(storeCode.toString()); // 구독 해제 함수
      storeCodeForRequest = -1;
    }

    print("cancel waiting/cancel/$storeCode");
    var unsubscribeFunctionCancle = _subscribeCancle[storeCode.toString()];
    if (unsubscribeFunctionCancle != null) {
      // Map<String, String> 타입을 명시하여 타입 에러를 해결
      unsubscribeFunctionCancle(unsubscribeHeaders: <String, String>{});
      _subscribeCancle[storeCode.toString()] = null; // 올바른 null 할당
      _subscribeCancle.remove(storeCode.toString()); // 구독 해제 함수 삭제
      storeCodeForCancle = -1;
    }

    state = null;
    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    final json_data_status = jsonEncode(state);
    print("saveWaitingRequest : $json_data_status");
    await _storage.write(key: 'waitingStatus', value: json_data_status);
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadWaitingRequestList() async {
    print("loadWaitingRequest");
    final json_data_status = await _storage.read(key: 'waitingStatus');
    print("loadWaitingRequest : $json_data_status");

    if (json_data_status != null) {
      print("json_data_status : $json_data_status");
      // JSON 데이터가 존재하면 상태를 업데이트하고 구독을 시작합니다.
      state = StoreWaitingRequest.fromJson(jsonDecode(json_data_status));
      // 안전을 위해 state가 정상적으로 설정되었는지 다시 확인
      if (state != StoreWaitingRequest.nullValue() &&
          state!.token.storeCode != -1) {
        print("state.status : ${state!.status}");
        print("state.token.storeCode : ${state!.token.storeCode}");
        print("state.token.phoneNumber : ${state!.token.phoneNumber}");
        print("state.token.personNumber : ${state!.token.personNumber}");
        print("state.token.waiting : ${state!.token.waiting}");

        print(
            "StoreWaitingRequest.nullValue.status : ${StoreWaitingRequest.nullValue().status}");
        print(
            "StoreWaitingRequest.nullValue.token.storeCode : ${StoreWaitingRequest.nullValue().token.storeCode}");
        print(
            "StoreWaitingRequest.nullValue.token.phoneNumber : ${StoreWaitingRequest.nullValue().token.phoneNumber}");
        print(
            "StoreWaitingRequest.nullValue.token.personNumber : ${StoreWaitingRequest.nullValue().token.personNumber}");
        print(
            "StoreWaitingRequest.nullValue.token.waiting : ${StoreWaitingRequest.nullValue().token.waiting}");

        print("state is not null");
        print(
            "state != StoreWaitingRequest.nullValue() : ${state != StoreWaitingRequest.nullValue()}");
        print("state!.token.storeCode != -1 : ${state!.token.storeCode != -1}");
        print("storeCode : ${state!.token.storeCode}");
        print("state!.token.storeCode : ${state!.token.storeCode}");
        subscribeToStoreWaitingCancleRequest(
            state!.token.storeCode, state!.token.phoneNumber);
      } else {
        print("state is null");
        state = null;
      }
    } else {
      // JSON 데이터가 없을 때는 상태를 null로 설정하고 추가 작업을 수행하지 않습니다.
      print("json_data_status is null");
      state = null;
    }
  }

  void clearWaitingRequestList() {
    print("clearWaitingRequestList");
    if (state != null) {
      unSubscribe(state!.token.storeCode);
    }
  }

  void reconnect() {
    _client?.activate();
    print("storeWaitingInfo reconnect");
    loadWaitingRequestList();
    if (state != null) {
      print("reconnect : ${state!.token.storeCode}");
      subscribeToStoreWaitingCancleRequest(
          state!.token.storeCode, state!.token.phoneNumber);
    }
  }
}
