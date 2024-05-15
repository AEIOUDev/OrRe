// import 'dart:io';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/error/error_screen.dart';
import 'package:orre/presenter/error/network_error_screen.dart';
import 'package:orre/presenter/error/server_error_screen.dart';
import 'package:orre/presenter/error/websocket_error_screen.dart';
import 'package:orre/presenter/homescreen/home_screen.dart';
import 'package:orre/presenter/location/location_manager_screen.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/first_boot_future_provider.dart';
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

import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';

import 'package:orre/services/network/https_services.dart';

import 'package:orre/widget/text/text_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase를 현재 플랫폼에 맞게 초기화

  initializeFirebaseMessaging(); // Firebase 메시징 초기화

  requestPermission(); // 권한 요청

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

  runApp(ProviderScope(child: OrreMain()));
}

final initStateProvider = StateProvider<int>((ref) => 3);

class OrreMain extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int initState = ref.watch(initStateProvider);
    List<Widget> nextScreen = [
      OnboardingScreen(),
      LocationStateCheckWidget(),
      WebsocketErrorScreen(),
      NetworkCheckScreen(),
      ErrorScreen(),
    ];
    return MaterialApp(
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.white,
        onInit: () async {
          debugPrint("On Init");
          initState = await initializeApp(ref);
          ref.read(initStateProvider.notifier).state = initState;
        },
        onEnd: () {
          debugPrint("On End");
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("assets/images/orre_logo.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: nextScreen[initState],
      ),
      title: '오리',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
    );
  }

  Widget TotalEnd(BuildContext context, WidgetRef ref) {
    // Future.delayed(Duration.zero, () {
    // if (connectState) {
    //   ref
    //       .read(errorStateNotifierProvider.notifier)
    //       .deleteError(Error.network);
    // } else {
    //   ref.read(errorStateNotifierProvider.notifier).addError(Error.network);
    // }

    //   if (locationPermission.isGranted) {
    //     ref
    //         .read(errorStateNotifierProvider.notifier)
    //         .deleteError(Error.locationPermission);
    //   } else {
    //     ref
    //         .read(errorStateNotifierProvider.notifier)
    //         .addError(Error.locationPermission);
    //   }

    //   if (stomp == StompStatus.CONNECTED) {
    //     ref
    //         .read(errorStateNotifierProvider.notifier)
    //         .deleteError(Error.websocket);
    //   } else {
    //     ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
    //   }
    // });

    print(
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    // print(connectState);
    print(
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    return MaterialApp(
      home: FutureBuilder(
        future: ref.read(userInfoProvider.notifier).loadUserInfo(),
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
      title: '오리',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/loginScreen': (context) => OnboardingScreen(),
      },
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

class NetworkCheckScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(networkStateNotifierProvider);

    return isConnected ? StompCheckScreen() : NetworkErrorScreen();
  }
}

class StompCheckScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: ref
            .watch(stompClientStateNotifierProvider.notifier)
            .configureClient(),
        builder: (context, snapshot) {
          print("StompCheckScreen() 호출 : ${snapshot.data}");
          if (snapshot.data != StompStatus.CONNECTED) {
            print("Stomp 에러 발생, WebsocketErrorScreen() 호출");
            return WebsocketErrorScreen();
          } else {
            print("Stomp 연결 성공, UserInfoCheckWidget() 호출");
            return UserInfoCheckWidget();
          }
        });
  }
}

class UserInfoCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: ref.watch(userInfoProvider.notifier).requestSignIn(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              print("유저 정보 존재 : ${snapshot.data}");
              print("LocationStateCheckWidget() 호출");
              return LocationStateCheckWidget();
            } else {
              print("OnboardingScreen() 호출");
              return OnboardingScreen();
            }
          } else {
            print("유저 정보 로딩 중");
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class LocationStateCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final connectState = ref.watch(networkStateNotifier);
    final location =
        ref.watch(nowLocationProvider.notifier).updateNowLocation();

    //
    return FutureBuilder(
        future: location,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              print("위치 정보 존재 : ${snapshot.data}");
              print("LoadServiceLogWidget() 호출");
              return LoadServiceLogWidget();
            } else {
              print("위치 정보 없음, LocationManagementScreen() 호출");
              return LocationManagementScreen();
            }
          } else {
            print("위치 정보 로딩 중");
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class LoadServiceLogWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo == null) {
      // 유저 정보 없음
      print("유저 정보 없음, UserInfoCheckWidget() 호출");
      return UserInfoCheckWidget();
    } else {
      // 유저 정보 있음
      print("유저 정보 존재 : ${userInfo.phoneNumber}");
      print("ServiceLogWidget() 호출");
      return FutureBuilder(
          future: ref
              .watch(serviceLogProvider.notifier)
              .fetchStoreServiceLog(userInfo.phoneNumber),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              if (APIResponseStatus.serviceLogFailure
                  .isEqualTo(snapshot.data!.status)) {
                // 서비스 로그 불러오기 실패
                print("서비스 로그 불러오기 실패, 재로그인 필요 : OnboardingScreen() 호출");
                return OnboardingScreen();
              } else {
                // 서비스 로그 불러오기 성공. 나열 시작
                print("서비스 로그 불러오기 성공 : ${snapshot.data!.userLogs.length}");

                return MainScreen();
              }
            } else {
              print("서비스 정보 로딩 중");
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          });
    }
  }
}

Future<void> initializeFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('orre'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('orre'),
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}
