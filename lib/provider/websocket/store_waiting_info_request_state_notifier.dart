import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreWaitingRequest {
  final int storeCode;
  final String userName;
  final String userPhoneNumber;
  final bool success;
  final String message;
  final int waiting;
  final int status;
  final int personNumber;

  StoreWaitingRequest({
    required this.storeCode,
    required this.userName,
    required this.userPhoneNumber,
    required this.success,
    required this.message,
    required this.waiting,
    required this.status,
    required this.personNumber,
  });

  factory StoreWaitingRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingRequest(
        storeCode: 0,
        userName: '',
        userPhoneNumber: '',
        success: false,
        message: '',
        waiting: -1,
        status: -1,
        personNumber: -1,
      );
    }

    return StoreWaitingRequest(
      storeCode: json['storeCode'] ?? 0,
      userName: json['userName'] ?? '',
      userPhoneNumber: json['userPhoneNumber'] ?? '',
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      waiting: json['waiting'] ?? -1,
      status: json['status'] ?? -1,
      personNumber: json['personNumber'] ?? -1,
    );
  }
}

final storeWaitingRequestNotifierProvider =
    StateNotifierProvider<StoreWaitingRequestNotifier, StoreWaitingRequest?>(
        (ref) {
  return StoreWaitingRequestNotifier([]);
});

class StoreWaitingRequestNotifier extends StateNotifier<StoreWaitingRequest?> {
  StompClient? _client;
  late int _storeCode;
  late String _userPhoneNumber;
  late int _personNumber;

  StoreWaitingRequestNotifier(List<StoreWaitingRequest> initialState)
      : super(null);

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
    _storeCode = storeCode;
    _userPhoneNumber = userPhoneNumber;
    _personNumber = personNumber;

    _client?.subscribe(
      destination: '/topic/user/waiting/make/$_storeCode/$_userPhoneNumber',
      callback: (frame) {
        if (frame.body != null) {
          print("subscribeToStoreWaitingRequest : ${frame.body}");
          var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
          if (decodedBody is Map<String, dynamic>) {
            // 첫 번째 요소를 추출하고 StoreWaitingRequest 인스턴스로 변환
            var firstResult = StoreWaitingRequest.fromJson(decodedBody);
            print("firstResult : ${firstResult.storeCode}");
            print("firstResult : ${firstResult.userName}");
            print("firstResult : ${firstResult.userPhoneNumber}");
            print("firstResult : ${firstResult.success}");
            print("firstResult : ${firstResult.message}");
            print("firstResult : ${firstResult.waiting}");
            print("firstResult : ${firstResult.status}");
            print("firstResult : ${firstResult.personNumber}");

            state = firstResult;
          }
          print("state : $state");
        }
      },
    );
    print("StoreWaitingRequestList/${storeCode} : subscribe!");
    sendWaitingRequest();
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendWaitingRequest() {
    print(
        "sendWaitingRequest : {$_storeCode}, {$_userPhoneNumber}, {$_personNumber}");
    _client?.send(
      destination: '/app/user/waiting/make/$_storeCode/$_userPhoneNumber',
      body: json.encode({
        "phoneNumber": _userPhoneNumber,
        "storeCode": _storeCode,
        "personNumber": _personNumber,
      }),
    );
  }

  void unSubscribe() {
    dynamic unsubscribeFn = _client?.subscribe(
        destination:
            '/topic/user/waiting/make/{$_storeCode}/{$_userPhoneNumber}',
        headers: {},
        callback: (frame) {
          // Received a frame for this subscription
          print(frame.body);
        });
    unsubscribeFn(unsubscribeHeaders: {});
  }

  @override
  void dispose() {
    unSubscribe();
    super.dispose();
  }
}
