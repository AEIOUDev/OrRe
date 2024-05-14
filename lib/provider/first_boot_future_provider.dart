import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';

Future<int> initializeApp(WidgetRef ref) async {
  try {
    final networkStatusStream = ref.watch(networkStateProvider);
    bool isConnected = false;
    StreamSubscription<bool>? subscription;

    final completer = Completer<void>();

    subscription = networkStatusStream.listen((status) {
      if (status) {
        isConnected = true;
        subscription?.cancel();
        completer.complete();
      }
    });

    // 10초 후에 타임아웃 처리
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (!completer.isCompleted) {
        subscription?.cancel();
        completer.completeError('Timeout');
      }
    });

    await completer.future;

    if (isConnected) {
      // 네트워크 연결이 되어 있을 때 자동 로그인 시도
      print("네트워크 연결 성공");
      final result =
          await ref.read(userInfoProvider.notifier).requestSignIn(null);
      ref.read(userInfoProvider.notifier).clearUserInfo();
      if (result == null) {
        print("로그인 정보 없음");
        return 0; // 로그인 정보 없음
      } else {
        print("로그인 정보 있음. 유저 명 : ${result.toString()}");
        return 1; // 로그인 성공
      }
    } else {
      print("네트워크 연결 실패");
      return 2; // 네트워크 연결 실패 시 false 반환
    }
  } catch (e) {
    print("에러 발생 : $e");
    return 3; // 에러 발생 시 false 반환
  }
}
