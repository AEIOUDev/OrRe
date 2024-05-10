import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/error/error_screen.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/permission/location_permission_state_notifier.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // Firebase 초기화 옵션을 포함한 파일
import 'presenter/storeinfo/store_info_screen.dart';
import 'presenter/user/onboarding_screen.dart';
import 'services/notifications_services.dart';

import 'presenter/main_screen.dart';

import 'provider/userinfo/user_info_state_notifier.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:get/get.dart';

import 'package:orre/provider/network/connectivity_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // ); // Firebase를 현재 플랫폼에 맞게 초기화

  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: true,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // print('User granted permission: ${settings.authorizationStatus}');
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print(fcmToken);

  // FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
  //   if (message != null) {
  //     if (message.notification != null) {
  //       print(message.notification!.title);
  //       print(message.notification!.body);
  //       print(message.data["click_action"]);
  //     }
  //   }
  // });

  // final notificationService = NotificationService();
  // notificationService.listenNotifications();

  // 네이버 지도 초기화

  if (!GetPlatform.isWeb) {
    await NaverMapSdk.instance.initialize(clientId: "mlravb678f");

    await NaverMapSdk.instance.initialize(
        clientId: 'your client id',
        onAuthFailed: (ex) {
          print("********* 네이버맵 인증오류 : $ex *********");
        });
  }

  setPathUrlStrategy(); // 해시(#) 없이 URL 사용

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("MyApp build() called");
    final connectState = ref.watch(networkStateNotifier);
    final locationPermission =
        ref.watch(locationPermissionStateNotifierProvider);
    final stomp = ref.watch(stompState);

    Future.delayed(Duration.zero, () {
      if (connectState) {
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.network);
      } else {
        ref.read(errorStateNotifierProvider.notifier).addError(Error.network);
      }

      if (locationPermission.isGranted) {
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.locationPermission);
      } else {
        ref
            .read(errorStateNotifierProvider.notifier)
            .addError(Error.locationPermission);
      }

      if (stomp == StompStatus.CONNECTED) {
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.websocket);
      } else {
        ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
      }
    });

    print(
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(connectState);
    print(
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if (ref.read(errorStateNotifierProvider.notifier).hasError) {
      print("ErrorScreen() called");
      return MaterialApp(
        home: ErrorScreen(),
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
      );
    } else {
      return MaterialApp(
        home: FutureBuilder(
          future: startInitialScreen(ref),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print("snapshot.data is ${snapshot.data}");
              if (snapshot.data != null) {
                return MainScreen();
              } else {
                print("OnboardingScreen() called");
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
}

Future<String?> startInitialScreen(WidgetRef ref) async {
  ref.read(locationListProvider.notifier).loadLocations();
  ref.read(nowLocationProvider.notifier).updateNowLocation();
  return await ref.read(userInfoProvider.notifier).requestSignIn(null);
}
