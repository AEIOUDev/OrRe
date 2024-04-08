import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../waiting_usercall_time_list_state_notifier.dart';

class UserCall {
  final int storeCode;
  final int waitingNumber;
  final DateTime entryTime;

  UserCall({
    required this.storeCode,
    required this.waitingNumber,
    required this.entryTime,
  });

  factory UserCall.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserCall(
        storeCode: 0,
        waitingNumber: 0,
        entryTime: DateTime.now(),
      );
    }

    return UserCall(
      storeCode: json['storeCode'],
      waitingNumber: json['waitingTeam'],
      entryTime: DateTime.parse(json['entryTime']),
    );
  }
}

final storeWaitingUserCallNotifierProvider =
    StateNotifierProvider<StoreWaitingUserCallNotifier, List<UserCall>>((ref) {
  return StoreWaitingUserCallNotifier(ref, []);
});

class StoreWaitingUserCallNotifier extends StateNotifier<List<UserCall>> {
  StompClient? _client;
  late final Ref _ref;
  Map<int, dynamic> _subscribeUserCall = {}; // 구독 해제 함수를 저장할 변수 추가

  StoreWaitingUserCallNotifier(Ref ref, List<UserCall> initialState)
      : super([]) {
    _ref = ref;
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("UserCall : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToUserCall(
    int storeCode,
    int waitingNumber,
  ) {
    if (_subscribeUserCall[storeCode] == null) {
      _subscribeUserCall[storeCode] = _client?.subscribe(
        destination: '/topic/user/userCall/$storeCode/$waitingNumber',
        callback: (frame) {
          if (frame.body != null) {
            print("subscribeToUserCall : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            // 첫 번째 요소를 추출하고 UserCall 인스턴스로 변환
            var userCall = UserCall.fromJson(decodedBody);

            updateOrAddUserCall(userCall); // UserCall 객체를 추가하거나 업데이트
          }
        },
      );
      print("UserCallList/${storeCode} : subscribe!");
    } else {
      print("UserCallList/${storeCode} : already subscribed!");
    }
  }

  void updateOrAddUserCall(UserCall userCall) {
    var existingIndex =
        indexOfUserCall(userCall.storeCode, userCall.waitingNumber);
    if (existingIndex != -1) {
      state[existingIndex] = userCall;
      state = List.from(state);
    } else {
      state = [...state, userCall];
    }
    _ref
        .read(waitingUserCallTimeListProvider.notifier)
        .setUserCallTime(userCall.entryTime);
  }

  int indexOfUserCall(int storeCode, int waitingNumber) {
    return state.indexWhere((info) =>
        info.storeCode == storeCode && info.waitingNumber == waitingNumber);
  }

  UserCall? getUserCall(int storeCode, int waitingNumber) {
    var existingIndex = indexOfUserCall(storeCode, waitingNumber);
    if (existingIndex != -1) {
      return state[existingIndex];
    } else {
      return null;
    }
  }

  void unSubscribe(int storeCode, int waitingNumber) {
    print("unSubscribe /user/userCall/$storeCode/$waitingNumber");
    _subscribeUserCall[storeCode](unsubscribeHeaders: null); // 구독 해제 함수 호출
    _subscribeUserCall[storeCode].remove(); // 구독 해제 함수 삭제
    _subscribeUserCall[storeCode] = null; // 구독 해제 함수 초기화
    print("_unsubscribeUserCall : ${_subscribeUserCall[storeCode]}");

    final List<UserCall> willChangeState = List.from(state);
    willChangeState.removeWhere((element) =>
        element.storeCode == storeCode &&
        element.waitingNumber == waitingNumber);
    state = willChangeState;

    _ref.read(waitingUserCallTimeListProvider.notifier).deleteTimer();
  }
}
