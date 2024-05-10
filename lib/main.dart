import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // Firebase 초기화 옵션을 포함한 파일
import 'presenter/storeinfo/store_info_screen.dart';
import 'presenter/user/onboarding_screen.dart';
import 'services/notifications_services.dart';

import 'presenter/main_screen.dart';

import 'provider/userinfo/user_info_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase를 현재 플랫폼에 맞게 초기화

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: true,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);

  // 네이버 지도 초기화
  await NaverMapSdk.instance.initialize(clientId: "mlravb678f");

  await NaverMapSdk.instance.initialize(
      clientId: 'your client id',
      onAuthFailed: (ex) {
        print("********* 네이버맵 인증오류 : $ex *********");
      });

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
    if (message != null) {
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print(message.data["click_action"]);
      }
    }
  });

  final notificationService = NotificationService();
  notificationService.listenNotifications();

  setPathUrlStrategy(); // 해시(#) 없이 URL 사용

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("MyApp build() called");
    ref.read(stompClientStateNotifierProvider.notifier).configureClient();
    return MaterialApp(
      home: FutureBuilder(
        future: startInitialScreen(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              print("snapshot.data is True");
              return MainScreen();
            } else {
              print("snapshot.data is False");
              return OnboardingScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // 경로 이름 파싱
        Uri uri = Uri.parse(settings.name!);
        // '/reservation/{가게코드}' 경로 처리
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'reservation') {
          int storeCode = int.parse(uri.pathSegments[1]);
          // return MaterialPageRoute(
          //     builder: (context) => WaitingInfoWidget(storeCode: storeCode));
          return MaterialPageRoute(
              builder: (context) =>
                  StoreDetailInfoWidget(storeCode: storeCode));
        }
        return null;
      },
    );
  }
}

Future<bool> startInitialScreen(WidgetRef ref) async {
  ref.read(locationListProvider.notifier).loadLocations();
  return await ref.read(userInfoProvider.notifier).loadUserInfo();
}
