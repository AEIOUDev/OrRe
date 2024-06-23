import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/services/debug_services.dart';
import 'package:stomp_dart_client/stomp.dart';

import '../../../model/store_service_log_model.dart';
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
    printd("UserCall : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    // loadWaitingRequestList();
  }

  void subscribeToUserCall(
    int storeCode,
    int waitingNumber,
  ) {
    printd("subscribeToUserCall : $storeCode, $waitingNumber");
    _subscribeUserCall.forEach((key, value) {
      printd("subscribeUserCall : $key");
      printd("subscribeUserCall : $value");
    });
    if (_subscribeUserCall[storeCode] == null) {
      _subscribeUserCall[storeCode] = _client?.subscribe(
        destination:
            '${dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREWAITINGUSERCALL_SUBSCRIBE')}$storeCode/$waitingNumber',
        callback: (frame) {
          if (frame.body != null) {
            printd("subscribeToUserCall : ${frame.body}");
            var decodedBody = json.decode(frame.body!); // JSON 문자열을 객체로 변환
            // 첫 번째 요소를 추출하고 UserCall 인스턴스로 변환
            var userCall = UserCall.fromJson(decodedBody);
            _ref.read(userCallAlertProvider.notifier).state = true;
            updateOrAddUserCall(userCall); // UserCall 인스턴스를 저장
          }
        },
      );
      printd("UserCallList/${storeCode} : subscribe!");
    } else {
      printd("UserCallList/${storeCode} : already subscribed!");
    }
  }

  void updateOrAddUserCall(UserCall userCall) {
    state = userCall;
    saveWaitingRequestList();
    _ref
        .read(waitingUserCallTimeListProvider.notifier)
        .setUserCallTime(userCall.entryTime);

    _ref
        .read(waitingStatus.notifier)
        .setWaitingStatus(StoreWaitingStatus.CALLED);
  }

  void unSubscribe() {
    printd("unSubscribe UserCall");
    _subscribeUserCall.forEach((key, value) {
      if (value != null) {
        printd("unSubscribe UserCall : $key");
        value(unsubscribeHeaders: <String, String>{}); // 구독 해제 함수 호출
        printd("unSubscribe UserCall : $value");
      } else {
        printd("unSubscribe UserCall is null for key: $key");
      }
    });
    printd("unSubscribe UserCall : ${_subscribeUserCall.length}");
    _subscribeUserCall.clear();
    state = null;
    _ref.read(userCallAlertProvider.notifier).state = false;
    _ref.read(waitingUserCallTimeListProvider.notifier).deleteTimer();

    saveWaitingRequestList();
  }

  // 위치 정보 리스트를 안전한 저장소에 저장
  Future<void> saveWaitingRequestList() async {
    printd("saveUserCallStatus");

    if (state == null) {
      if (await _storage.containsKey(key: 'userCallStatus')) {
        await _storage.delete(key: 'userCallStatus');
      }
    } else {
      UserCall userCall = state as UserCall;
      final json_data_status = jsonEncode(userCall.toJson());
      printd("saveUserCallStatus : $json_data_status");
      await _storage.write(key: 'userCallStatus', value: json_data_status);
    }
  }

  // 안전한 저장소에 저장된 위치 정보 리스트를 불러오는 메소드
  Future<void> loadWaitingRequestList() async {
    printd("loadUserCallStatus");
    try {
      bool keyExists = await _storage.containsKey(key: 'userCallStatus');
      if (!keyExists) {
        printd("키체인에 'userCallStatus' 키가 존재하지 않습니다.");
        state = null;
        return;
      }

      final jsonDataStatus = await _storage.read(key: 'userCallStatus');
      if (jsonDataStatus != null) {
        printd("loadUserCallStatus : $jsonDataStatus");
        final UserCall userCall = UserCall.fromJson(jsonDecode(jsonDataStatus));
        state = userCall;
        subscribeToUserCall(userCall.storeCode, userCall.waitingNumber);
        _ref
            .read(waitingUserCallTimeListProvider.notifier)
            .setUserCallTime(userCall.entryTime);
      } else {
        state = null;
      }
    } on Error catch (e) {
      printd('키체인 오류: ${e}');
      state = null;
    } catch (e) {
      printd('예상치 못한 오류: $e');
      state = null;
    }
  }

  void repairUserCallStateByServiceLog(UserLogs userLog) {
    printd("repairUserCallStateByServiceLog");
    final newState = UserCall(
      storeCode: userLog.storeCode,
      waitingNumber: userLog.waiting,
      entryTime: userLog.calledTimeOut ?? DateTime.now(),
    );

    state = newState;
  }
}
