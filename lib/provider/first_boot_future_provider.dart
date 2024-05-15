import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';

Future<int> initializeApp(WidgetRef ref) async {
  try {
    final networkStatus = ref.read(networkStateNotifierProvider);
    if (!networkStatus) {
      print("네트워크 연결 실패");
      return 3; // 네트워크 연결 실패 시 3 반환
    }

    // 네트워크 연결이 되어 있을 때 STOMP 연결 확인
    print("네트워크 연결 성공");
    final stompStatusStream =
        ref.read(stompClientStateNotifierProvider.notifier).configureClient();
    bool isStompConnected = false;
    StreamSubscription<StompStatus>? stompSubscription;

    final stompCompleter = Completer<void>();

    stompSubscription = stompStatusStream.listen((status) {
      if (status == StompStatus.CONNECTED) {
        isStompConnected = true;
        stompSubscription?.cancel();
        stompCompleter.complete();
      }
    });

    // 10초 후에 타임아웃 처리
    final stompTimeout = Future.delayed(const Duration(seconds: 10), () {
      if (!stompCompleter.isCompleted) {
        stompSubscription?.cancel();
        stompCompleter.completeError('STOMP timeout');
      }
    });

    await Future.any([stompCompleter.future, stompTimeout]);

    if (isStompConnected) {
      // STOMP 연결이 성공했을 때 자동 로그인 시도
      print("STOMP 연결 성공");
      final result =
          await ref.read(userInfoProvider.notifier).requestSignIn(null);
      if (result == null) {
        print("로그인 정보 없음");
        return 0; // 로그인 정보 없음
      } else {
        print("로그인 정보 있음. 유저 명 : ${result.toString()}");
        return 1; // 로그인 성공
      }
    } else {
      print("STOMP 연결 실패");
      return 2; // STOMP 연결 실패
    }
  } catch (e) {
    print("에러 발생 : $e");
    return 4; // 에러 발생 시 4 반환
  }
}
