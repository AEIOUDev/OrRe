import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreWaitingInfo {
  final int storeCode;
  final List<int> waitingTeamList;
  final List<int> enteringTeamList;
  final int estimatedWaitingTimePerTeam;

  StoreWaitingInfo({
    required this.storeCode,
    required this.waitingTeamList,
    required this.enteringTeamList,
    required this.estimatedWaitingTimePerTeam,
  });

  factory StoreWaitingInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingInfo(
        storeCode: 0,
        waitingTeamList: [],
        enteringTeamList: [],
        estimatedWaitingTimePerTeam: 0,
      );
    }

    return StoreWaitingInfo(
      storeCode: json['storeCode'] ?? 0,
      waitingTeamList: List<int>.from(json['waitingTeamList'] ?? []),
      enteringTeamList: List<int>.from(json['enteringTeamList'] ?? []),
      estimatedWaitingTimePerTeam: json['estimatedWaitingTimePerTeam'] ?? 0,
    );
  }
}

final storeWaitingInfoNotifierProvider =
    StateNotifierProvider<StoreWaitingInfoListNotifier, List<StoreWaitingInfo>>(
        (ref) {
  return StoreWaitingInfoListNotifier([]);
});

class StoreWaitingInfoListNotifier
    extends StateNotifier<List<StoreWaitingInfo>> {
  StompClient? _client;
  final Set<int> _subscribedStoreCodes = {};
  Map<String, dynamic> subscriptions = {};

  StoreWaitingInfoListNotifier(List<StoreWaitingInfo> initialState)
      : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingInfoList : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToStoreWaitingInfo(int storeCode) {
    if (_subscribedStoreCodes.contains(storeCode)) {
      print("StoreWaitingInfoList/${storeCode} : already subscribed!");
      return;
    } else {
      print("subscribedStoreCodes : ${_subscribedStoreCodes}");
      print("getWaitingTeamsList : ${getWaitingTeamsList(storeCode)}");
    }

    var subscription = _client?.subscribe(
      destination: '/topic/user/dynamicStoreWaitingInfo/$storeCode',
      callback: (frame) {
        if (frame.body != null) {
          print("subscribeToStoreWaitingInfo : ${frame.body}");
          var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
          if (decodedBody is Map<String, dynamic>) {
            // 첫 번째 요소를 추출하고 StoreWaitingInfo 인스턴스로 변환
            var firstResult = StoreWaitingInfo.fromJson(decodedBody);
            // print("firstResult : ${firstResult.storeCode}");
            // print("firstResult : ${firstResult.enteringTeamList}");
            // print("firstResult : ${firstResult.waitingTeamList}");
            // print("firstResult : ${firstResult.estimatedWaitingTimePerTeam}");

            // 이미 있는 storeCode인 경우, 해당 요소의 내용을 업데이트
            var existingIndex = state
                .indexWhere((info) => info.storeCode == firstResult.storeCode);
            if (existingIndex != -1) {
              state[existingIndex] = firstResult;
              state = List.from(state);
            } else {
              // 새로운 요소를 상태에 추가
              state = [...state, firstResult];
            }
          }
          // print("state : $state");
        }
      },
    );
    subscriptions['$storeCode'] = subscription;
    _subscribedStoreCodes.add(storeCode);
    print("StoreWaitingInfoList/${storeCode} : subscribe!");
    sendStoreCode(storeCode);
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendStoreCode(int storeCode) {
    print("sendStoreCode : ${storeCode}");
    _client?.send(
      destination: '/app/user/dynamicStoreWaitingInfo/${storeCode}',
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribeAll() {
    print("unSubscribeAll");
    subscriptions.forEach((storeCode, unsubscribeFn) {
      unsubscribeFn();
      print("unSubscribeAll/${storeCode} : unsubscribe!");
    });
    // 모든 구독을 해제한 후, 구독 목록을 초기화
    subscriptions.clear();
    _subscribedStoreCodes.clear();

    print(
        "subscribed_subscribedStoreCodesStoreCodes : ${_subscribedStoreCodes}");
    print("subscribedsubscriptionsStoreCodes : ${subscriptions}");
  }

  List<int> getWaitingTeamsList(int storeCode) {
    final storeWaitingInfo =
        state.firstWhere((info) => info.storeCode == storeCode,
            orElse: () => StoreWaitingInfo(
                  storeCode: 0,
                  waitingTeamList: [],
                  enteringTeamList: [],
                  estimatedWaitingTimePerTeam: 0,
                ));
    return storeWaitingInfo.waitingTeamList;
  }

  @override
  void dispose() {
    unSubscribeAll();
    super.dispose();
  }
}
