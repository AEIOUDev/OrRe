import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_waiting_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/debug_services.dart';

final firstStoreWaitingListLoaded = StateProvider<bool>((ref) => false);

final storeWaitingInfoNotifierProvider =
    StateNotifierProvider<StoreWaitingInfoListNotifier, List<StoreWaitingInfo>>(
        (ref) {
  return StoreWaitingInfoListNotifier([]);
});

class StoreWaitingInfoListNotifier
    extends StateNotifier<List<StoreWaitingInfo>> {
  StompClient? _client;
  Map<int, dynamic> _subscriptions = {};

  StoreWaitingInfoListNotifier(List<StoreWaitingInfo> initialState)
      : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreWaitingInfoList : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToStoreWaitingInfo(int storeCode) {
    if (_subscriptions[storeCode] == null) {
      print("subscribedStoreCodes : ${storeCode}");
      print("getWaitingTeamsList : ${getWaitingTeamsList(storeCode)}");
      _subscriptions[storeCode] = _client?.subscribe(
        destination: dotenv
                .get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFOLIST_SUBSCRIBE') +
            storeCode.toString(),
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToStoreWaitingInfo : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            if (decodedBody is Map<String, dynamic>) {
              // 첫 번째 요소를 추출하고 StoreWaitingInfo 인스턴스로 변환
              var firstResult = StoreWaitingInfo.fromJson(decodedBody);
              printd("가게 웨이팅 리스트 정보 : ${firstResult.waitingTeamList}");

              // 이미 있는 storeCode인 경우, 해당 요소의 내용을 업데이트
              var existingIndex = state.indexWhere(
                  (info) => info.storeCode == firstResult.storeCode);
              if (existingIndex != -1) {
                // 이 때 기존 상태와 새로운 상태가 동일하다면 업데이트하지 않음
                if (state[existingIndex] == firstResult) {
                  printd("state[existingIndex] == firstResult");
                  return;
                } else {
                  // 기존 상태와 새로운 상태가 다르다면 업데이트
                  printd("state[existingIndex] != firstResult");
                  state[existingIndex] = firstResult;
                  state = List.from(state);
                  saveState();
                }
              } else {
                // 새로운 요소를 상태에 추가
                state = [...state, firstResult];
                // saveState();
              }
            }
            // print("state : $state");
          }
        },
      );
      // print("StoreWaitingInfoList/${storeCode} : subscribe!");
      sendStoreCode(storeCode);
    } else {
      print("StoreWaitingInfoList/${storeCode} : already subscribed!");
    }
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendStoreCode(int storeCode) {
    print("sendStoreCode : ${storeCode}");
    _client?.send(
      destination:
          dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGINFOLIST_REQUEST') +
              storeCode.toString(),
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribeAll() {
    print("unSubscribe All of StoreWaitingInfoListNotifier");
    _subscriptions.forEach((storeCode, unsubscribeFn) {
      unsubscribeFn();
      print("unSubscribeAll/${storeCode} : unsubscribe!");
    });
    // 모든 구독을 해제한 후, 구독 목록을 초기화
    _subscriptions.clear();

    print("subscribedsubscriptionsStoreCodes : ${_subscriptions}");
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

  void clearWaitingInfoList() {
    printd("clearWaitingInfoList");
    _subscriptions.clear();
    state = [];
  }

  void saveState() async {
    printd("StoreWaitingInfoList : saveState");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<StoreWaitingInfo> storeWaitingInfoList = state;
    String encodedList = json.encode(storeWaitingInfoList);
    prefs.setString('waitingInfoList', encodedList);
  }

  Future<List<StoreWaitingInfo>> loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedList = prefs.getString('waitingInfoList');
    if (encodedList != null) {
      print("waitingInfoList loadState encodedList : $encodedList");
      List<dynamic> decodedList = json.decode(encodedList);
      state = decodedList
          .map((e) => StoreWaitingInfo.fromJson(e))
          .toList(); // JSON 문자열을 객체로 변환
      // saveState();
      return state;
    }
    return [];
  }

  StoreWaitingInfo getStoreWaitingInfo(int storeCode) {
    final storeWaitingInfo =
        state.firstWhere((info) => info.storeCode == storeCode,
            orElse: () => StoreWaitingInfo(
                  storeCode: 0,
                  waitingTeamList: [],
                  enteringTeamList: [],
                  estimatedWaitingTimePerTeam: 0,
                ));
    return storeWaitingInfo;
  }

  Stream<StoreWaitingInfo> getStoreWaitingInfoStream(int storeCode) {
    return Stream.fromIterable(state)
        .where((info) => info.storeCode == storeCode);
  }

  void reconnect() {
    print("StoreWaitingInfoListNotifier reconnect");
    unSubscribeAll();
    loadState().then((value) {
      value.forEach((element) {
        print("reconnect : ${element.storeCode}");
        subscribeToStoreWaitingInfo(element.storeCode);
      });
    });
  }

  @override
  void dispose() {
    unSubscribeAll();
    super.dispose();
  }
}
