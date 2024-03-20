import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../services/websocket_services.dart';

class StoreWaitingInfo {
  final String storeCode;
  final String storeName;
  final int storeInfoVersion;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;
  final dynamic menuInfo;

  StoreWaitingInfo({
    required this.storeCode,
    required this.storeName,
    required this.storeInfoVersion,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
    this.menuInfo,
  });

  factory StoreWaitingInfo.fromJson(Map<String, dynamic> json) {
    return StoreWaitingInfo(
      storeCode: json['storeCode'].toString(),
      storeName: json['storeName'],
      storeInfoVersion: json['storeInfoVersion'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
      menuInfo: json['menuInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'storeName': storeName,
      'storeInfoVersion': storeInfoVersion,
      'numberOfTeamsWaiting': numberOfTeamsWaiting,
      'estimatedWaitingTime': estimatedWaitingTime,
      'menuInfo': menuInfo,
    };
  }
}

// 리스트로 StoreWaitingInfo 객체를 관리하는 프로바이더를 정의합니다.
final storeWaitingListProvider =
    StateNotifierProvider<StoreWaitingListNotifier, List<StoreWaitingInfo>>(
        (ref) {
  return StoreWaitingListNotifier([]);
});

// StateNotifier를 확장하여 리스트를 관리하는 클래스를 정의합니다.
class StoreWaitingListNotifier extends StateNotifier<List<StoreWaitingInfo>> {
  StoreWaitingListNotifier(List<StoreWaitingInfo> state) : super(state);

  late StompClient stompClient;

  void setupStompClient() {
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://192.168.1.214:8080/ws',
        url: WebSocketService.url,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    stompClient.activate();
  }

  void subscribeStoreInfo() {
    stompClient.subscribe(
      destination: '/topic/user/storeInfo',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final newInfo = StoreWaitingInfo.fromJson(json.decode(frame.body!));
          // 상태 업데이트 로직을 추가합니다.
          _updateOrAddNewInfo(newInfo);
        }
      },
    );
    print("storeWaitingInfo : onConnect!");
  }

  // 동일한 storeCode를 가진 객체를 업데이트하거나 새로운 객체를 추가합니다.
  void _updateOrAddNewInfo(StoreWaitingInfo newInfo) {
    print(newInfo);
    int index = state.indexWhere((info) => info.storeCode == newInfo.storeCode);
    if (index != -1) {
      // 이미 리스트에 존재하는 경우 정보를 업데이트합니다.
      state[index] = newInfo;
    } else {
      // 새로운 정보를 리스트에 추가합니다.
      state = [...state, newInfo];
    }
  }

  // NFC 스캔 후 storeCode를 보내는 메서드
  void sendStoreCode(String storeCode) {
    print(storeCode);
    stompClient.send(
      destination: '/app/user/storeInfo',
      body: json.encode({"storeCode": storeCode}),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }

  void removeWaiting(StoreWaitingInfo item) {
    state = state.where((info) => info.storeCode != item.storeCode).toList();
  }
}
