import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storeWaitingRequestNotifierProvider =
    StateNotifierProvider<StoreWaitingRequestNotifier, StoreWaitingRequest?>(
        (ref) {
  return StoreWaitingRequestNotifier(ref);
});

class StoreWaitingRequestNotifier extends StateNotifier<StoreWaitingRequest?> {
  StompClient? _client;

  final _storage = FlutterSecureStorage();

  // Map<int, Completer> completers = {};

  dynamic _subscribeRequest = {};
  dynamic _subscribeCancle = {};

  StoreWaitingRequestNotifier(Ref ref) : super(null) {}

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingRequest : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    loadWaitingRequestList();
  }

  Future<bool> startSubscribe(
      int storeCode, String userPhoneNumber, int personNumber) async {
    print("startSubscribe : $storeCode, $userPhoneNumber, $personNumber");
    if (_client != null) {
      // 웨이팅 요청을 위한 구독을 요청하고, 성공 시 웨이팅 취소 구독도 요청
      if (await subscribeToStoreWaitingRequest(
          storeCode, userPhoneNumber, personNumber)) {
        print("WaitingRequest waitingSubscribeComplete : Success");

        // 웨이팅 요청 성공 시, 웨이팅 취소도 구독 시도
        if (await subscribeToStoreWaitingCancleRequest(
            storeCode, userPhoneNumber)) {
          print("WaitingRequest waitingCancleSubcribeComplete : Success");
          return true;
        } else {
          // TODO : 웨이팅 취소 요청 실패 시, 모든 구독을 해제하고 false 반환
          print("WaitingRequest waitingCancleSubcribeComplete : Fail");
          return false;
        }
      } else {
        // TODO : 웨이팅 요청 실패 시, 모든 구독을 해제하고 false 반환
        print("WaitingRequest waitingSubscribeComplete : Fail");
        return false;
      }
    } else {
      // StompClient가 null인 경우, false 반환
      print("StompClient is null");
      // _client?.activate();
      return false;
    }
  }

  Future<bool> subscribeToStoreWaitingRequest(
    int storeCode,
    String userPhoneNumber,
    int personNumber,
  ) async {
    Completer<bool> completer = Completer<bool>();

    // 이미 구독 중인 경우 이전 구독을 취소하고 새로 시작합니다.
    if (_subscribeRequest != null) {
      _subscribeRequest(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      print(
          "StoreWaitingRequestList/${storeCode} : Unsubscribed previous subscription!");
    }

    _subscribeRequest = _client?.subscribe(
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
            print("Error decoding data: $e");
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        } else {
          print("subscribeToStoreWaitingRequest : body is null");
          completer.complete(false);
        }
      },
    );

    return completer.future;
  }

  Future<bool> subscribeToStoreWaitingCancleRequest(
    int storeCode,
    String userPhoneNumber,
  ) async {
    Completer<bool> completer = Completer<bool>();

    // 이미 구독 중인 경우 이전 구독을 취소하고 새로 시작합니다.
    if (_subscribeCancle != null) {
      _subscribeCancle(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      print(
          "StoreWaitingRequestList/${storeCode} : Unsubscribed previous subscription!");
    }
    _subscribeCancle = _client?.subscribe(
      destination: '/topic/user/waiting/cancel/$storeCode/$userPhoneNumber',
      callback: (frame) {
        if (frame.body != null) {
          print("subscribeToStoreWaitingCancleRequest : ${frame.body}");
          try {
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
              print("웨이팅 취소 성공!!");
              waitingCancelProcess(true, storeCode, userPhoneNumber);
              completer.complete(true);
            } else if (APIResponseStatus.waitingCancleByStore
                .isEqualTo(decodedBody['status'])) {
              print("가게에서 취소!!");
              waitingCancelProcess(true, storeCode, userPhoneNumber);
              completer.complete(false);
            } else {
              print("웨이팅 취소 실패!!");
              waitingCancelProcess(false, storeCode, userPhoneNumber);
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

    return completer.future;
  }

  // 웨이팅 요청을 서버로 전송하는 메소드
  void sendWaitingRequest(
      int storeCode, String userPhoneNumber, int personNumber) {
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
  }

  void sendWaitingCancleRequest(int storeCode, String userPhoneNumber) {
    print("sendWaitingCancleRequest : {$storeCode}, {$userPhoneNumber}");
    _client?.send(
      destination: '/app/user/waiting/cancel/$storeCode/$userPhoneNumber',
      body: json.encode({
        "userPhoneNumber": userPhoneNumber,
        "storeCode": storeCode,
      }),
    );
  }

  void waitingAddProcess(StoreWaitingRequest result) {
    if (APIResponseStatus.success.isEqualTo(result.status)) {
      state = result;
      _subscribeRequest(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      _subscribeRequest = null;
      saveWaitingRequestList();
    } else {
      print(result.token);
    }
  }

  void waitingCancelProcess(bool result, int storeCode, String phoneNumber) {
    print("waitingCancelProcess : $result, $storeCode, $phoneNumber");
    if (result) {
      print("waitingCancelProcessSuccess : $result, $storeCode, $phoneNumber");
      state = null;
      unSubscribe(storeCode);
    } else {
      print(result);
    }
  }

  void unSubscribe(int storeCode) {
    print("cancle waiting/make/$storeCode");
    if (_subscribeRequest != null) {
      _subscribeRequest(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      _subscribeRequest == null;
      _subscribeRequest.remove(storeCode); // 구독 해제 함수
    }

    print("cancle waiting/cancle/$storeCode");
    if (_subscribeCancle != null) {
      _subscribeCancle!(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      _subscribeCancle == null;
      _subscribeCancle.remove(storeCode); // 구독 해제 함수 삭제
    }
    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    print("saveWaitingRequestList");
    final json_data_subscribe = jsonEncode(_subscribeCancle);
    await _storage.write(
        key: 'subscriptionDetails', value: json_data_subscribe);
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadWaitingRequestList() async {
    print("loadWaitingRequestList");
    final json_data_subscribe = await _storage.read(key: 'subscriptionDetails');
    if (json_data_subscribe != null) {
      _subscribeCancle = jsonDecode(json_data_subscribe);
    }
  }

  void clearWaitingRequestList() {
    state = null;
    _subscribeCancle = null;
    _subscribeRequest = null;
    saveWaitingRequestList();
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
