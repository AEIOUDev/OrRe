import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storeWaitingRequestNotifierProvider = StateNotifierProvider<
    StoreWaitingRequestNotifier, List<StoreWaitingRequest>>((ref) {
  return StoreWaitingRequestNotifier(ref, []);
});

class StoreWaitingRequestNotifier
    extends StateNotifier<List<StoreWaitingRequest>> {
  StompClient? _client;
  // late final Ref _ref;

  final _storage = FlutterSecureStorage();

  Map<int, void Function({Map<String, String>? unsubscribeHeaders})?>
      _subscribeWaiting = {}; // 구독 해제 함수를 저장할 변수 추가
  Map<int, void Function({Map<String, String>? unsubscribeHeaders})?>
      _subscribeWaitingCancle = {}; // 구독 해제 함수를 저장할 변수 추가

  List<StoreWaitingRequest> _subscriptionInfo = [];

  StoreWaitingRequestNotifier(Ref ref, List<StoreWaitingRequest> initialState)
      : super([]) {
    // _ref = ref;
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingRequest : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    loadWaitingRequestList();
  }

  Stream<bool> startSubscribe(
      int storeCode, String userPhoneNumber, int personNumber) {
    print("startSubscribe : $storeCode, $userPhoneNumber, $personNumber");
    StreamController<bool> controller = StreamController<bool>();
    bool waitingSubscribeComplete = false;
    bool waitingCancleSubcribeComplete = false;
    if (_client != null) {
      subscribeToStoreWaitingRequest(storeCode, userPhoneNumber, personNumber)
          .listen((event) {
        if (event) {
          waitingSubscribeComplete = true;
          print(
              "WaitingRequest waitingSubscribeComplete : $waitingSubscribeComplete");
        } else {
          controller.add(false);
        }
      });
      subscribeToStoreWaitingCancleRequest(storeCode, userPhoneNumber)
          .listen((event) {
        if (event) {
          waitingCancleSubcribeComplete = true;
          print(
              "WaitingRequest waitingCancleSubcribeComplete : $waitingCancleSubcribeComplete");
        } else {
          controller.add(false);
        }
      });
      print(
          "both subscribe complete? : ${waitingSubscribeComplete} / ${waitingCancleSubcribeComplete}");
      if (waitingSubscribeComplete && waitingCancleSubcribeComplete) {
        controller.add(true);
      }
    } else {
      print("StompClient is null");
      _client?.activate();
      controller.add(false);
    }

    return controller.stream;
  }

  Stream<bool> subscribeToStoreWaitingRequest(
    int storeCode,
    String userPhoneNumber,
    int personNumber,
  ) {
    StreamController<bool> controller = StreamController<bool>();
    print(
        "_subscribeWaiting[$storeCode] : ${_subscribeWaiting[storeCode].toString()}");
    _subscribeWaiting.forEach((key, value) {
      print('key : $key, value : $value');
    });
    if (_subscribeWaiting[storeCode] == null) {
      _subscribeWaiting[storeCode] = _client?.subscribe(
        destination: '/topic/user/waiting/make/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingRequest : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
              print("웨이팅 참여 성공!!");
              var firstResult = StoreWaitingRequest.fromJson(decodedBody);
              waitingAddProcess(firstResult);
              controller.add(true);
            } else {
              print("웨이팅 참여 실패!!");
              controller.add(false);
            }
          } else {
            print("subscribeToStoreWaitingRequest : body is null");
            controller.add(false); // body가 null인 경우
          }
        },
      );
      print("StoreWaitingRequestList/${storeCode} : subscribe!");
    } else {
      print("StoreWaitingRequestList/${storeCode} : already subscribed!");
      controller.add(false); // 이미 구독중인 경우
    }

    return controller.stream; // 생성된 스트림 반환
  }

  Stream<bool> subscribeToStoreWaitingCancleRequest(
    int storeCode,
    String userPhoneNumber,
  ) {
    StreamController<bool> controller = StreamController<bool>();

    if (_subscribeWaitingCancle[storeCode] == null) {
      print(
          "_subscribeWaiting[$storeCode] : ${_subscribeWaitingCancle[storeCode].toString()}");
      _subscribeWaitingCancle.forEach((key, value) {
        print('key : $key, value : $value');
      });
      _subscribeWaitingCancle[storeCode] = _client?.subscribe(
        destination: '/topic/user/waiting/cancel/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingCancleRequest : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (APIResponseStatus.success.isEqualTo(decodedBody['status'])) {
              print("웨이팅 취소 성공!!");
              waitingCancelProcess(true, storeCode, userPhoneNumber);
              return controller.add(true);
            } else if (APIResponseStatus.waitingCancleByStore
                .isEqualTo(decodedBody['status'])) {
              print("가게에서 취소!!");
              waitingCancelProcess(true, storeCode, userPhoneNumber);
              return controller.add(true);
            } else {
              print("웨이팅 취소 실패!!");
              waitingCancelProcess(false, storeCode, userPhoneNumber);
              return controller.add(false);
            }
          }
        },
      );
      print("StoreWaitingCancleRequestList/${storeCode} : subscribe!");
    } else {
      print("StoreWaitingCancleRequestList/${storeCode} : already subscribed!");
      controller.add(false); // 이미 구독중인 경우
    }

    return controller.stream; // 생성된 스트림 반환
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
      state = [...state, result];
      saveWaitingRequestList();
    } else {
      print(result.token);
    }
  }

  void waitingCancelProcess(bool result, int storeCode, String phoneNumber) {
    print("waitingCancelProcess : $result, $storeCode, $phoneNumber");
    print("state : ${state.length}");
    if (result) {
      print("waitingCancelProcessSuccess : $result, $storeCode, $phoneNumber");
      final newState = List<StoreWaitingRequest>.from(state);
      newState.removeWhere((element) =>
          element.token.storeCode == storeCode &&
          element.token.phoneNumber == phoneNumber);
      state = newState;
      print("newState : ${newState.length}");
      unSubscribe(storeCode);
    } else {
      print(result);
    }
  }

  StoreWaitingRequest? searchWaitingRequest(int storeCode, String phoneNumber) {
    final waitingRequest = state.firstWhere(
        (element) =>
            element.token.storeCode == storeCode &&
            element.token.phoneNumber == phoneNumber,
        orElse: () => StoreWaitingRequest.nullValue());

    if (APIResponseStatus.success.isEqualTo(waitingRequest.status)) {
      print('waiting: ${waitingRequest.token.waiting}');
      return waitingRequest;
    } else {
      print('waiting: ${waitingRequest.token}');
      return null;
    }
  }

  void unSubscribe(int storeCode) {
    print("cancle waiting/make/$storeCode");
    if (_subscribeWaiting[storeCode] != null) {
      _subscribeWaiting[storeCode]!(unsubscribeHeaders: {}); // 구독 해제 함수 호출
      _subscribeWaiting[storeCode] == null;
      _subscribeWaiting.remove(storeCode); // 구독 해제 함수
    }

    print("cancle waiting/cancle/$storeCode");
    if (_subscribeWaitingCancle[storeCode] != null) {
      _subscribeWaitingCancle[storeCode]!(
          unsubscribeHeaders: {}); // 구독 해제 함수 호출
      _subscribeWaitingCancle[storeCode] == null;
      _subscribeWaitingCancle.remove(storeCode); // 구독 해제 함수 삭제
    }

    _subscriptionInfo
        .removeWhere((element) => element.token.storeCode == storeCode);
    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    print("saveWaitingRequestList");
    final json_data_subscribe =
        jsonEncode(state.map((e) => e.toJson()).toList());

    await _storage.write(
        key: 'subscriptionDetails', value: json_data_subscribe);
  }

  // 저장소에서 위치 정보 리스트 로드
  Future<void> loadWaitingRequestList() async {
    print("loadWaitingRequestList");
    final json_data_subscribe = await _storage.read(key: 'subscriptionDetails');
    if (json_data_subscribe != null) {
      final List<dynamic> decodedData = jsonDecode(json_data_subscribe);
      _subscriptionInfo = decodedData
          .map((e) => StoreWaitingRequest.fromJson(e))
          .toList(); // JSON 문자열을 객체로 변환
      state = _subscriptionInfo;
    }
  }

  void clearWaitingRequestList() {
    state = [];
    _subscribeWaiting.clear();
    _subscribeWaitingCancle.clear();
    _subscriptionInfo.clear();
    saveWaitingRequestList();
  }

  void reconnect() {
    _client?.activate();
    print("storeWaitingInfo reconnect");
    loadWaitingRequestList();
    state.forEach((element) {
      subscribeToStoreWaitingRequest(
        element.token.storeCode,
        element.token.phoneNumber,
        element.token.personNumber,
      );
      subscribeToStoreWaitingCancleRequest(
        element.token.storeCode,
        element.token.phoneNumber,
      );
    });
  }
}
