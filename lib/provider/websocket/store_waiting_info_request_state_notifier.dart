import 'dart:convert';
import 'dart:ffi';

import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreWaitingRequest {
  final bool success;
  final String message;
  final StoreWaitingRequestDetail waitingDetails;

  StoreWaitingRequest({
    required this.success,
    required this.message,
    required this.waitingDetails,
  });

  factory StoreWaitingRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingRequest(
        success: false,
        message: '',
        waitingDetails: StoreWaitingRequestDetail(
          storeCode: 0,
          phoneNumber: '',
          waiting: -1,
          status: -1,
          personNumber: -1,
        ),
      );
    }

    return StoreWaitingRequest(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      waitingDetails:
          StoreWaitingRequestDetail.fromJson(json['waitingDetails']),
    );
  }
}

class StoreWaitingRequestDetail {
  final String phoneNumber;
  final int storeCode;
  final int waiting;
  final int status;
  final int personNumber;

  StoreWaitingRequestDetail({
    required this.storeCode,
    required this.phoneNumber,
    required this.waiting,
    required this.status,
    required this.personNumber,
  });

  factory StoreWaitingRequestDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingRequestDetail(
        storeCode: 0,
        phoneNumber: '',
        waiting: -1,
        status: -1,
        personNumber: -1,
      );
    }

    return StoreWaitingRequestDetail(
      storeCode: json['storeCode'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      waiting: json['waiting'] ?? -1,
      status: json['status'] ?? -1,
      personNumber: json['personNumber'] ?? -1,
    );
  }
}

final storeWaitingRequestNotifierProvider = StateNotifierProvider<
    StoreWaitingRequestNotifier, List<StoreWaitingRequest>>((ref) {
  return StoreWaitingRequestNotifier(ref, []);
});

class StoreWaitingRequestNotifier
    extends StateNotifier<List<StoreWaitingRequest>> {
  StompClient? _client;
  late final Ref _ref;
  Map<int, dynamic> _subscribeWaiting = {}; // 구독 해제 함수를 저장할 변수 추가
  Map<int, dynamic> _subscribeWaitingCancle = {}; // 구독 해제 함수를 저장할 변수 추가

  StoreWaitingRequestNotifier(Ref ref, List<StoreWaitingRequest> initialState)
      : super([]) {
    _ref = ref;
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingRequest : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToStoreWaitingRequest(
    int storeCode,
    String userPhoneNumber,
    int personNumber,
  ) {
    if (_subscribeWaiting[storeCode] == null) {
      _subscribeWaiting[storeCode] = _client?.subscribe(
        destination: '/topic/user/waiting/make/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingRequest : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (decodedBody is Map<String, dynamic>) {
              // 첫 번째 요소를 추출하고 StoreWaitingRequest 인스턴스로 변환
              var firstResult = StoreWaitingRequest.fromJson(decodedBody);
              print("firstResult : ${firstResult.success}");
              print("firstResult : ${firstResult.message}");
              print("firstResult : ${firstResult.waitingDetails.storeCode}");
              print("firstResult : ${firstResult.waitingDetails.phoneNumber}");
              print("firstResult : ${firstResult.waitingDetails.waiting}");
              print("firstResult : ${firstResult.waitingDetails.status}");
              print("firstResult : ${firstResult.waitingDetails.personNumber}");
              waitingAddProcess(firstResult);
            }
            print("state : $state");
          }
        },
      );
      print("StoreWaitingRequestList/${storeCode} : subscribe!");
      sendWaitingRequest(storeCode, userPhoneNumber, personNumber);
    } else {
      print("StoreWaitingRequestList/${storeCode} : already subscribed!");
    }
  }

  void subscribeToStoreWaitingCancleRequest(
    int storeCode,
    String userPhoneNumber,
  ) {
    if (_subscribeWaitingCancle[storeCode] == null) {
      _subscribeWaitingCancle[storeCode] = _client?.subscribe(
        destination: '/topic/user/waiting/cancel/$storeCode/$userPhoneNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingCancleRequest : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (decodedBody is Map<String, dynamic>) {
              // 첫 번째 요소를 추출하고 StoreWaitingRequest 인스턴스로 변환
              var firstResult = StoreWaitingRequest.fromJson(decodedBody);
              print("firstResult : ${firstResult.success}");
              print("firstResult : ${firstResult.message}");
              print("firstResult : ${firstResult.waitingDetails.storeCode}");
              print("firstResult : ${firstResult.waitingDetails.phoneNumber}");
              print("firstResult : ${firstResult.waitingDetails.waiting}");
              print("firstResult : ${firstResult.waitingDetails.status}");
              print("firstResult : ${firstResult.waitingDetails.personNumber}");
              waitingCancelProcess(
                  firstResult.success, storeCode, userPhoneNumber);
            }
            print("state : $state");
          }
        },
      );
      print("StoreWaitingCancleRequestList/${storeCode} : subscribe!");
      sendWaitingCancleRequest(storeCode, userPhoneNumber);
    } else {
      print("StoreWaitingCancleRequestList/${storeCode} : already subscribed!");
    }
  }

  // 웨이팅 요청을 서버로 전송하는 메소드
  void sendWaitingRequest(
      int storeCode, String userPhoneNumber, int personNumber) {
    print(
        "sendWaitingRequest : {$storeCode}, {$userPhoneNumber}, {$personNumber}");
    _client?.send(
      destination: '/app/user/waiting/make/$storeCode/$userPhoneNumber',
      body: json.encode({
        "phoneNumber": userPhoneNumber,
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
        "phoneNumber": userPhoneNumber,
        "storeCode": storeCode,
      }),
    );
  }

  void waitingAddProcess(StoreWaitingRequest result) {
    if (result.success) {
      state = [...state, result];
    } else {
      print(result.message);
    }
  }

  void waitingCancelProcess(bool result, int storeCode, String phoneNumber) {
    if (result) {
      final newState = List<StoreWaitingRequest>.from(state);
      newState.removeWhere((element) =>
          element.waitingDetails.storeCode == storeCode &&
          element.waitingDetails.phoneNumber == phoneNumber);
      unSubscribe(storeCode);
      state = newState;
    } else {
      print(result);
    }
  }

  StoreWaitingRequest? searchWaitingRequest(int storeCode, String phoneNumber) {
    final waitingRequest = state.firstWhere(
        (element) =>
            element.waitingDetails.storeCode == storeCode &&
            element.waitingDetails.phoneNumber == phoneNumber,
        orElse: () => StoreWaitingRequest(
              success: false,
              message: '',
              waitingDetails: StoreWaitingRequestDetail(
                storeCode: 0,
                phoneNumber: '',
                waiting: -1,
                status: -1,
                personNumber: -1,
              ),
            ));

    if (waitingRequest.success) {
      print('waiting: ${waitingRequest.waitingDetails.waiting}');
      return waitingRequest;
    } else {
      print('waiting: ${waitingRequest.message}');
      return null;
    }
  }

  void unSubscribe(int storeCode) {
    print("waiting/make/$storeCode");
    _subscribeWaiting[storeCode](unsubscribeHeaders: null); // 구독 해제 함수 호출
    _subscribeWaiting.remove(storeCode); // 구독 해제 함수 삭제

    print("waiting/cancle/$storeCode");
    _subscribeWaitingCancle[storeCode](unsubscribeHeaders: null); // 구독 해제 함수 호출
    _subscribeWaitingCancle.remove(storeCode); // 구독 해제 함수 삭제
  }
}
