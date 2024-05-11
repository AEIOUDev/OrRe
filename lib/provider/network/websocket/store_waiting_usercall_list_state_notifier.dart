import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../waiting_usercall_time_list_state_notifier.dart';

final userCallAlertProvider = StateProvider<bool>((ref) {
  return false;
});

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

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'waitingTeam': waitingNumber,
      'entryTime': entryTime.toIso8601String(),
    };
  }
}

final storeWaitingUserCallNotifierProvider =
    StateNotifierProvider<StoreWaitingUserCallNotifier, UserCall?>((ref) {
  return StoreWaitingUserCallNotifier(ref);
});

class StoreWaitingUserCallNotifier extends StateNotifier<UserCall?> {
  StompClient? _client;
  late final Ref _ref;
  final _storage = FlutterSecureStorage();
  Map<int, dynamic> _subscribeUserCall = {}; // 구독 해제 함수를 저장할 변수 추가

  StoreWaitingUserCallNotifier(Ref ref) : super(null) {
    _ref = ref;
  }

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("UserCall : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    loadWaitingRequestList();
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
            _ref.read(userCallAlertProvider.notifier).state = true;
            updateOrAddUserCall(userCall); // UserCall 인스턴스를 저장
          }
        },
      );
      print("UserCallList/${storeCode} : subscribe!");
    } else {
      print("UserCallList/${storeCode} : already subscribed!");
    }
  }

  void updateOrAddUserCall(UserCall userCall) {
    state = userCall;
    saveWaitingRequestList();
    _ref
        .read(waitingUserCallTimeListProvider.notifier)
        .setUserCallTime(userCall.entryTime);
  }

  void unSubscribe(int storeCode, int waitingNumber) {
    print("unSubscribe /user/userCall/$storeCode/$waitingNumber");
    if (_subscribeUserCall[storeCode] == null) {
      print("UserCallList/${storeCode} : not subscribed!");
      return;
    }
    _subscribeUserCall[storeCode](unsubscribeHeaders: null); // 구독 해제 함수 호출
    _subscribeUserCall[storeCode] = null; // 구독 해제 함수 초기화
    print("_unsubscribeUserCall : ${_subscribeUserCall[storeCode]}");

    state = null;

    _ref.read(waitingUserCallTimeListProvider.notifier).deleteTimer();

    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    print("saveUserCallStatus");
    if (state == null) {
      return;
    }
    final json_data_status = jsonEncode(state!.toJson());
    print("saveUserCallStatus : $json_data_status");
    await _storage.write(key: 'userCallStatus', value: json_data_status);
  }

  // 안전한 저장소에 저장된 위치 정보 리스트를 불러오는 메소드
  Future<void> loadWaitingRequestList() async {
    print("loadUserCallStatus");
    final json_data_status = await _storage.read(key: 'userCallStatus');
    if (json_data_status != null) {
      print("loadUserCallStatus : $json_data_status");
      final UserCall userCall = UserCall.fromJson(jsonDecode(json_data_status));
      state = userCall;
      subscribeToUserCall(userCall.storeCode, userCall.waitingNumber);
      _ref
          .read(waitingUserCallTimeListProvider.notifier)
          .setUserCallTime(userCall.entryTime);
    } else {
      state = null;
    }
  }

  void reconnect() {
    print("reconnect UserCall");
    loadWaitingRequestList();
  }
}
