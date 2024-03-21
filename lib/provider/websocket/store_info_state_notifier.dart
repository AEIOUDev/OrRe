import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StoreDetailInfo {
  final int storeCode;
  final String storeName;
  final int storeInfoVersion;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;
  final List<dynamic> menuInfo;

  StoreDetailInfo({
    required this.storeCode,
    required this.storeName,
    required this.storeInfoVersion,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
    required this.menuInfo,
  });

  factory StoreDetailInfo.fromJson(Map<String, dynamic> json) {
    return StoreDetailInfo(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeInfoVersion: json['storeInfoVersion'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
      menuInfo: json['menuInfo'],
    );
  }
}

// StoreInfo 객체를 관리하는 프로바이더를 정의합니다.
final storeInfoProvider =
    StateNotifierProvider<StoreInfoNotifier, StoreDetailInfo?>((ref) {
  return StoreInfoNotifier(null); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 StoreInfo 객체를 관리하는 클래스를 정의합니다.
class StoreInfoNotifier extends StateNotifier<StoreDetailInfo?> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가

  StoreInfoNotifier(StoreDetailInfo? initialState) : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreInfo : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    subscribeToStoreInfo(); // 구독 시작
  }

  void subscribeToStoreInfo() {
    _client?.subscribe(
      destination: '/topic/user/storeInfo',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          print("StoreInfo : subscribeToStoreInfo : ${frame.body}");
          try {
            // JSON 문자열을 파싱하여 StoreDetailInfo 객체로 변환
            final newInfo = StoreDetailInfo.fromJson(json.decode(frame.body!));
            // 상태를 업데이트합니다.
            state = newInfo;
          } catch (e) {
            print("Error parsing store info: $e");
          }
        }
      },
    );
    print("StoreInfo : subscribe!");
  }

  // NFC 스캔 후 storeCode를 보내는 메서드
  void sendStoreCode(int storeCode) {
    print("StoreInfo : sendStoreCode : $storeCode");
    _client?.send(
      destination: '/app/user/storeInfo',
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribe() {
    dynamic unsubscribeFn = _client?.subscribe(
        destination: '/topic/user/storeInfo',
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