import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/services/debug.services.dart';

Future<int> initializeApp(WidgetRef ref) async {
  printd("\n\ninitializeApp 진입");
  final isStompConnected = await stompConnectionCheck(ref);
  printd("isStompConnected : $isStompConnected");
  if (!isStompConnected) {
    printd("Stomp 연결 실패, 네트워크 체크 화면으로 이동");
    return 1;
  }

  final isLogin = await loginCheck(ref);
  printd("isLogin : $isLogin");
  if (!isLogin) {
    printd("로그인 실패, 로그인 화면으로 이동");
    return 2;
  }

  printd("\n\ninitializeApp 종료, 성공적으로 초기화 완료");
  return 0;
}

Future<bool> stompConnectionCheck(WidgetRef ref) async {
  printd("\n\nstompConnectionCheck 진입");
  final stompStatusStream =
      ref.read(stompClientStateNotifierProvider.notifier).configureClient();
  bool isStompConnected = false;
  StreamSubscription<StompStatus>? stompSubscription;

  final stompCompleter = Completer<void>();

  stompSubscription = stompStatusStream.listen((status) {
    try {
      if (status == StompStatus.CONNECTED) {
        isStompConnected = true;
        stompSubscription?.cancel();
        stompCompleter.complete();
      }
    } catch (e) {
      // Handle any errors that occur during stomp connection check
      print('Error occurred during stomp connection check: $e');
      stompCompleter.completeError(e);
    }
  });

  try {
    await stompCompleter.future;
    return isStompConnected;
  } catch (e) {
    // Handle any errors that occur during stomp connection check
    print('Error occurred during stomp connection check: $e');
    return false;
  }
}

Future<bool> loginCheck(WidgetRef ref) async {
  printd("\n\nloginCheck 진입");
  try {
    final result =
        await ref.read(userInfoProvider.notifier).requestSignIn(null);
    if (result == null) {
      return false;
    } else {
      return true;
    }
  } catch (e) {
    // Handle any errors that occur during login check
    print('Error occurred during login check: $e');
    return false;
  }
}
