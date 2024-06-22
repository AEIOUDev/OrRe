import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/services/debug_services.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/hardware/nfc_services.dart';
import 'app_state_provider.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<int> initializeApp(WidgetRef ref) async {
  printd("\n\ninitializeApp 진입");

  // await DefaultCacheManager().emptyCache();

  await nfcCheck(ref);

  try {
    final update = await updateCheck(ref);
    if (update != 0) {
      printd("업데이트 필요, 업데이트 화면으로 이동");
      return update;
    }
  } catch (e) {
    printd("업데이트 체크 실패, 서버 에러 화면 이동 : ${e.toString()}");
    return 4;
  }

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

Future<void> nfcCheck(WidgetRef ref) async {
  printd("\n\nnfcCheck 진입");
  final isNFCAvailable = await NfcManager.instance.isAvailable();
  if (!isNFCAvailable) {
    printd("NFC 사용 불가로 설정");
    ref.read(nfcAvailableProvider.notifier).state = false;
  } else {
    printd("NFC 사용 가능으로 설정");
    ref.read(nfcAvailableProvider.notifier).state = true;
  }
}

Future<int> updateCheck(WidgetRef ref) async {
  printd("\n\nupdateCheck 진입");

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  ref.read(appVersionProvider.notifier).setAppVersion(packageInfo.version);

  final jsonBody = {
    'appCode': '1', // 오리의 경우 1
    'appVersion': packageInfo.version,
  };
  final jsonString = json.encode(jsonBody);

  final isNeedUpdate = await HttpsService.postUniRequest(
      dotenv.get('ORRE_HTTPS_ENDPOINT_UPDATECHECK'), jsonString);

  final isNeedUpdateResponse = json.decode(isNeedUpdate.body);
  printd("latestVersion : ${isNeedUpdateResponse['appVersion']}");
  ref
      .read(latestAppVersionProvider.notifier)
      .setLatestAppVersion(isNeedUpdateResponse['appVersion']);

  if (APIResponseStatus.appVersionDifferent
      .isEqualTo(isNeedUpdateResponse['status'])) {
    printd("앱 버전 다름 : ${isNeedUpdateResponse['appVersion']}");
    printd("업데이트 필요 유무 : ${isNeedUpdateResponse['appEssentialUpdate'] == 1}");
    // if (packageInfo.version != isNeedUpdateResponse['appVersion']) {
    if (isNeedUpdateResponse['appEssentialUpdate'] == 1) {
      printd("앱 업데이트 필요");
      return 3;
    } else {
      printd("앱 업데이트 불필요");
    }
  } else {
    printd("앱 버전 같음");
  }
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
      printd('Error occurred during stomp connection check: $e');
      stompCompleter.completeError(e);
    }
  });

  try {
    await stompCompleter.future;
    return isStompConnected;
  } catch (e) {
    // Handle any errors that occur during stomp connection check
    printd('Error occurred during stomp connection check: $e');
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
    printd('Error occurred during login check: $e');
    return false;
  }
}
