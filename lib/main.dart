// import 'dart:io';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:orre/presenter/error/network_error_screen.dart';
import 'package:orre/presenter/error/websocket_error_screen.dart';
import 'package:orre/presenter/location/add_location_screen.dart';
import 'package:orre/presenter/location/location_management_screen.dart';
import 'package:orre/presenter/user/sign_in_screen.dart';
import 'package:orre/presenter/user/sign_up_reset_password_screen.dart';
import 'package:orre/presenter/user/sign_up_screen.dart';
import 'package:orre/provider/first_boot_future_provider.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // Firebase 초기화 옵션을 포함한 파일
import 'package:go_router/go_router.dart';

import 'presenter/homescreen/home_screen.dart';
import 'presenter/permission/permission_request_location.dart';
import 'presenter/storeinfo/store_info_screen.dart';
import 'presenter/user/agreement_screen.dart';
import 'presenter/user/onboarding_screen.dart';

import 'presenter/main_screen.dart';

import 'presenter/waiting/waiting_screen.dart';
import 'provider/userinfo/user_info_state_notifier.dart';

import 'package:get/get.dart';

import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';

import 'package:orre/services/network/https_services.dart';

import 'services/debug.services.dart';
import 'widget/text/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final notifications = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase를 현재 플랫폼에 맞게 초기화

  initializeFirebaseMessaging(); // Firebase 메시징 초기화
  requestPermission(); // 권한 요청

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // 화면 방향을 세로로 고정

  // 네이버 지도 초기화
  if (!GetPlatform.isWeb) {
    await NaverMapSdk.instance
        .initialize(clientId: "mlravb678f", onAuthFailed: (ex) => print(ex));
  }

  setPathUrlStrategy(); // 해시(#) 없이 URL 사용

  runApp(ProviderScope(child: OrreMain()));
}

final initStateProvider = StateProvider<int>((ref) => 1);

final GoRouter _router = GoRouter(
  initialLocation: "/initial",
  observers: [RouterObserver()],
  routes: [
    GoRoute(
      path: '/initial',
      builder: (context, state) {
        printd("Navigating to InitialScreen, fullPath: ${state.fullPath}");
        return InitialScreen();
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode',
      builder: (context, state) {
        printd("Navigating to ReservationPage, fullPath: ${state.fullPath}");
        final storeCode = int.parse(state.pathParameters['storeCode']!);
        return StoreDetailInfoWidget(storeCode: storeCode);
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode/:userPhoneNumber',
      builder: (context, state) {
        printd(
            "Navigating to ReservationPage for Specific User, fullPath: ${state.fullPath}");
        // final storeCode = int.parse(state.pathParameters['storeCode']!);
        // final userPhoneNumber =
        state.pathParameters['userPhoneNumber']!.replaceAll('-', '');
        return WaitingScreen();
      },
    ),
    GoRoute(
        path: '/error/:error',
        builder: (context, state) {
          printd("Navigating to ErrorPage, fullPath: ${state.fullPath}");
          final error = state.pathParameters['error'];
          return ErrorPage(Exception(error));
        }),
    GoRoute(
      path: '/initial/:initState',
      builder: (context, state) {
        printd("Navigating to InitialScreen, fullPath: ${state.fullPath}");
        final initState = int.parse(state.pathParameters['initState']!);

        List<Widget> nextScreen = [
          LocationStateCheckWidget(),
          StompCheckScreen(),
          OnboardingScreen(),
        ];

        return nextScreen[initState];
      },
    ),
    GoRoute(
        path: '/user/onboarding',
        builder: (context, state) {
          printd("Navigating to OnboardingScreen, fullPath: ${state.fullPath}");
          return OnboardingScreen();
        }),
    GoRoute(
        path: '/user/signin',
        builder: (context, state) {
          printd("Navigating to SignInScreen, fullPath: ${state.fullPath}");
          return SignInScreen();
        }),
    GoRoute(
        path: '/user/agreement',
        builder: (context, state) {
          printd("Navigating to AgreementScreen, fullPath: ${state.fullPath}");
          return AgreementScreen();
        }),
    GoRoute(
        path: '/user/signup',
        builder: (context, state) {
          printd("Navigating to SignUpScreen, fullPath: ${state.fullPath}");
          return SignUpScreen();
        }),
    GoRoute(
      path: '/user/resetpassword',
      builder: (context, state) {
        printd(
            "Navigating to SignUpResetPasswordScreen, fullPath: ${state.fullPath}");
        return SignUpResetPasswordScreen();
      },
    ),
    GoRoute(
        path: '/locationCheck',
        builder: (context, state) {
          printd(
              "Navigating to LocationStateCheckWidget, fullPath: ${state.fullPath}");
          return LocationStateCheckWidget();
        }),
    GoRoute(
        path: '/stompCheck',
        builder: (context, state) {
          printd("Navigating to StompCheckScreen, fullPath: ${state.fullPath}");
          return StompCheckScreen();
        }),
    GoRoute(
        path: "/networkError",
        builder: (context, state) {
          printd(
              "Navigating to NetworkErrorScreen, fullPath: ${state.fullPath}");
          return NetworkErrorScreen();
        }),
    GoRoute(
        path: '/loadServiceLog',
        builder: (context, state) {
          printd(
              "Navigating to LoadServiceLogWidget, fullPath: ${state.fullPath}");
          return LoadServiceLogWidget();
        }),
    GoRoute(
        path: '/main',
        builder: (context, state) {
          printd("Navigating to MainScreen, fullPath: ${state.fullPath}");
          return MainScreen();
        }),
    GoRoute(
        path: '/waiting',
        builder: (context, state) {
          printd("Navigating to WaitingScreen, fullPath: ${state.fullPath}");
          return WaitingScreen();
        }),
    GoRoute(
        path: '/location/addLocation',
        builder: (context, state) {
          return AddLocationScreen();
        }),
    GoRoute(
        path: '/location/locationManagement',
        builder: (context, state) {
          return LocationManagementScreen();
        }),
    GoRoute(
        path: '/permission/location',
        builder: (context, state) {
          return PermissionRequestLocationScreen();
        }),
    GoRoute(
        path: '/home',
        builder: (context, state) {
          return HomeScreen();
        }),
    GoRoute(
        path: "/storeinfo/:storeCode",
        builder: (context, state) {
          final storeCode = int.parse(state.pathParameters['storeCode']!);
          return StoreDetailInfoWidget(storeCode: storeCode);
        }),
  ],
  errorBuilder: (context, state) {
    printd('Error: ${state.error}');
    return ErrorPage(state.error);
  },
);

class OrreMain extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nOrreMain 진입");
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, _) => Builder(
        builder: (context) => GlobalLoaderOverlay(
          useDefaultLoading: false,
          overlayWidgetBuilder: (progress) {
            return CustomLoadingIndicator();
          },
          overlayColor: Colors.black.withOpacity(0.8),
          child: MaterialApp.router(
            routerConfig: _router,
            theme: ThemeData(
              primarySwatch: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget('Error'),
      ),
      body: Center(
        child: Text(error?.toString() ?? 'Unknown error'),
      ),
    );
  }
}

class InitialScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nInitialScreen 진입");

    return ConnectivityBuilder(
      interval: const Duration(seconds: 5),
      builder: (ConnectivityStatus status) {
        if (status == ConnectivityStatus.offline) {
          return NetworkErrorScreen();
        } else {
          return SplashScreen();
        }
      },
    );
  }
}

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nSplashScreen 진입");
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () async {
        debugPrint("On Init");
        ref.read(initStateProvider.notifier).state = await initializeApp(ref);
      },
      onEnd: () {
        debugPrint("On End");
        context.go('/initial/${ref.read(initStateProvider)}');
      },
      childWidget: SizedBox(
        height: 200.h,
        width: 200.w,
        child: Image.asset("assets/images/orre_logo.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
    );
  }
}

class StompCheckScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nStompCheckScreen 진입");
    // ignore: unused_local_variable
    final stomp = ref.watch(stompClientStateNotifierProvider);
    final stompS = ref.watch(stompState);

    if (stompS == StompStatus.CONNECTED) {
      // STOMP 연결 성공
      print("STOMP 연결 성공");
      return UserInfoCheckWidget();
    } else {
      // STOMP 연결 실패
      print("STOMP 연결 실패, WebsocketErrorScreen() 호출");
      return WebsocketErrorScreen();
    }
  }
}

class UserInfoCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nUserInfoCheckWidget 진입");
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
    printd("\n\nLocationStateCheckWidget 진입");

    return FutureBuilder(
        future: ref.watch(nowLocationProvider.notifier).updateNowLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              print("위치 정보 존재 : ${snapshot.data}");
              print("LoadServiceLogWidget() 호출");
              ref.read(locationListProvider.notifier).init();
              return LoadServiceLogWidget();
            } else {
              print("위치 정보 없음, PermissionRequestLocationScreen() 호출");
              return PermissionRequestLocationScreen();
            }
          } else {
            print("위치 정보 로딩 중");
            return Scaffold(
              body: CustomLoadingIndicator(),
            );
          }
        });
  }
}

class LoadServiceLogWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nLoadServiceLogWidget 진입");
    final userInfo = ref.watch(userInfoProvider);
    printd("userInfo: $userInfo");

    if (userInfo == null) {
      // 유저 정보 없음
      print("유저 정보 없음, UserInfoCheckWidget() 호출");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/userinfo_check');
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // 유저 정보 있음
      print("유저 정보 존재 : ${userInfo.phoneNumber}");
      print("ServiceLogWidget() 호출");

      return FutureBuilder(
        future: ref
            .watch(serviceLogProvider.notifier)
            .fetchStoreServiceLog(userInfo.phoneNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터 로딩 중
            print("서비스 정보 로딩 중");
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            if (APIResponseStatus.serviceLogPhoneNumberFailure
                .isEqualTo(snapshot.data!.status)) {
              // 서비스 로그 불러오기 실패
              print("서비스 로그 불러오기 실패, 재로그인 필요 : OnboardingScreen() 호출");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/onboarding');
              });
            } else {
              // 서비스 로그 불러오기 성공. 나열 시작
              print("서비스 로그 불러오기 성공 : ${snapshot.data!.userLogs.length}");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/main');
              });
            }
          } else if (snapshot.hasError) {
            // 에러 처리
            print("에러 발생: ${snapshot.error}");
          } else {
            // 기본 상태 (로딩 중)
            print("서비스 정보 로딩 중");
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }
  }
}

Future<void> initializeFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('orre'),
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await notifications.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      notifications.show(
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
            sound: const RawResourceAndroidNotificationSound('orre'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: "slow_spring_board.aiff",
          ),
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

class RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidPush: $route");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidPop: $route");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("DidRemove: $route");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print("DidReplace: $newRoute");
  }
}
