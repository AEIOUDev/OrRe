import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:orre/presenter/error/network_error_screen.dart';
import 'package:orre/presenter/error/server_error_screen.dart';
import 'package:orre/presenter/homescreen/service_log_screen.dart';
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

import 'model/store_service_log_model.dart';
import 'presenter/homescreen/home_screen.dart';
import 'presenter/homescreen/oss_licenses_screen.dart';
import 'presenter/homescreen/setting_screen.dart';
import 'presenter/initial/app_update_screen.dart';
import 'presenter/main/main_qr_scanner_screen.dart';
import 'presenter/permission/permission_checker_screen.dart';
import 'presenter/permission/permission_request_location.dart';
import 'presenter/permission/permission_request_phone.dart';
import 'presenter/storeinfo/store_info_screen.dart';
import 'presenter/user/agreement_screen.dart';
import 'presenter/user/onboarding_screen.dart';

import 'presenter/main/main_screen.dart';

import 'presenter/waiting/waiting_screen.dart';
import 'provider/userinfo/user_info_state_notifier.dart';

import 'package:get/get.dart';

import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';

import 'package:orre/services/network/https_services.dart';

import 'services/debug_services.dart';
import 'widget/text/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final notifications = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final _appLinks = AppLinks(); // AppLinks is singleton

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase를 현재 플랫폼에 맞게 초기화

  await initializeNotification(); // Firebase 메시징 초기화
  // requestPermission(); // 권한 요청

  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp]); // 화면 방향을 세로로 고정

  // 네이버 지도 초기화
  if (!GetPlatform.isWeb) {
    await NaverMapSdk.instance.initialize(
        clientId: dotenv.env['NAVER_API_ID']!, onAuthFailed: (ex) => print(ex));
  }

  setPathUrlStrategy(); // 해시(#) 없이 URL 사용

  runApp(ProviderScope(child: OrreMain()));
}

final initStateProvider = StateProvider<int>((ref) => 1);

final GoRouter _router = GoRouter(
  initialLocation: "/permission",
  observers: [RouterObserver()],
  routes: [
    GoRoute(
        path: "/permission",
        builder: (context, state) {
          return PermissionCheckerScreen();
        }),
    GoRoute(
      path: '/initial',
      pageBuilder: (context, state) {
        printd("Navigating to InitialScreen, fullPath: ${state.fullPath}");
        return NoTransitionPage(child: InitialScreen());
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
        // final userPhoneNumber = state.pathParameters['userPhoneNumber']!;

        // userPhoneNumber.replaceAll('-', '');
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
      pageBuilder: (context, state) {
        printd("Navigating to InitialScreen, fullPath: ${state.fullPath}");
        final initState = int.parse(state.pathParameters['initState']!);

        List<Widget> nextScreen = [
          LocationStateCheckWidget(),
          StompCheckScreen(),
          OnboardingScreen(),
          AppUpdateScreen(),
          ServerErrorScreen(),
        ];

        return NoTransitionPage(child: nextScreen[initState]);
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
        pageBuilder: (context, state) {
          printd(
              "Navigating to LocationStateCheckWidget, fullPath: ${state.fullPath}");
          return NoTransitionPage(child: LocationStateCheckWidget());
        }),
    GoRoute(
        path: '/stompCheck',
        pageBuilder: (context, state) {
          printd("Navigating to StompCheckScreen, fullPath: ${state.fullPath}");
          return NoTransitionPage(child: StompCheckScreen());
        }),
    GoRoute(
        path: "/networkError",
        pageBuilder: (context, state) {
          printd(
              "Navigating to NetworkErrorScreen, fullPath: ${state.fullPath}");
          return NoTransitionPage(child: NetworkErrorScreen());
        }),
    GoRoute(
        path: '/loadServiceLog',
        pageBuilder: (context, state) {
          printd(
              "Navigating to LoadServiceLogWidget, fullPath: ${state.fullPath}");
          return NoTransitionPage(child: LoadServiceLogWidget());
        }),
    GoRoute(
        path: '/main',
        pageBuilder: (context, state) {
          printd("Navigating to MainScreen, fullPath: ${state.fullPath}");
          return NoTransitionPage(child: MainScreen());
        },
        routes: [
          GoRoute(
            path: 'qrscanner',
            builder: (context, state) {
              return QRScannerScreen();
            },
          ),
        ]),
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
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: LocationManagementScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: Offset(0.0, -1.0), end: Offset.zero).chain(
                  CurveTween(curve: Curves.fastOutSlowIn),
                ),
              ),
              child: child,
            );
          },
        );
      },
    ),
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
    GoRoute(
        path: "/setting",
        builder: (context, state) {
          return SettingScreen();
        }),
    GoRoute(
        path: "/setting/servicelog",
        builder: (context, state) {
          return ServiceLogScreen();
        }),
    GoRoute(
        path: "/setting/licenses",
        builder: (context, state) {
          return OssLicensesPage();
        }),
    GoRoute(
        path: "/permission/phone",
        builder: (context, state) {
          return PermissionRequestPhoneScreen();
        }),
    GoRoute(
      path: "/permission/location",
      builder: (context, state) {
        return PermissionRequestLocationScreen();
      },
    ),
    GoRoute(
      path: '/userinfocheck',
      pageBuilder: (context, state) {
        return NoTransitionPage(child: UserInfoCheckWidget());
      },
    ),
    GoRoute(
      path: '/boot',
      builder: (context, state) {
        printd("Navigating to BootScreen, fullPath: ${state.fullPath}");
        return InitialScreen();
      },
      routes: [
        GoRoute(
          path: 'stompcheck',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: StompCheckScreen());
          },
        ),
        GoRoute(
          path: 'userinfocheck',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: UserInfoCheckWidget());
          },
        ),
        GoRoute(
          path: 'locationcheck',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: LocationStateCheckWidget());
          },
        ),
        GoRoute(
          path: 'loadservicelog',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: LoadServiceLogWidget());
          },
        ),
      ],
    ),
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
              primaryColor: const Color(0xFFFFBF52),
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

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    printd("\n\nSplashScreen 진입");

    ref.listen(initStateProvider, (previous, next) {
      if (previous != next) {
        context.go('/initial/${next}');
      }
    });

    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () async {
        debugPrint("On Init");
        final initState = await initializeApp(ref);
        if (mounted) {
          ref.read(initStateProvider.notifier).state = initState;
        }
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 200.h,
        width: 200.w,
        child: Image.asset("assets/images/orre_logo.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      duration: const Duration(milliseconds: 2000),
      animationDuration: const Duration(milliseconds: 2000),
    );
  }
}

class StompCheckScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nStompCheckScreen 진입");
    // ignore: unused_local_variable
    final stomp = ref.watch(stompClientStateNotifierProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stompS = ref.watch(stompState);

      if (stompS == StompStatus.CONNECTED) {
        // STOMP 연결 성공
        print("STOMP 연결 성공");
        context.go('/boot/userinfocheck');
      } else {
        // STOMP 연결 실패
        print("STOMP 연결 실패, WebsocketErrorScreen() 호출");
        context.go('/networkError');
      }
    });
    return Scaffold(
      body: CustomLoadingIndicator(
        message: "서버와 연결 확인 중..",
      ),
    );
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/locationCheck');
              });
            } else {
              print("OnboardingScreen() 호출");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/user/onboarding');
              });
            }
          }
          return Scaffold(
            body: CustomLoadingIndicator(message: "유저 정보를 불러오는 중.."),
          );
        });
  }
}

class LocationStateCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nLocationStateCheckWidget 진입");

    try {
      return FutureBuilder(
          future: ref.watch(nowLocationProvider.notifier).updateNowLocation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (snapshot.data != null) {
                  print("위치 정보 존재 : ${snapshot.data}");
                  print("LoadServiceLogWidget() 호출");
                  ref.read(locationListProvider.notifier).init();
                  context.go('/boot/loadservicelog');
                } else {
                  print("위치 정보 없음, PermissionRequestLocationScreen() 호출");
                  context.go('/permission/location');
                }
              });
            }
            return Scaffold(
              body: CustomLoadingIndicator(
                message: "위치 정보를 불러오는 중..",
              ),
            );
          });
    } catch (e) {
      print("\n\nLocationStateCheckWidget : ${e}");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/permission/location');
      });
      return Scaffold(
        body: CustomLoadingIndicator(
          message: "위치 정보를 불러오는 중 에러 발생.. 재시도 중..",
        ),
      );
    }
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
        context.go('/userinfocheck');
      });
      return Scaffold(
        body: CustomLoadingIndicator(
          message: "유저 정보를 불러오는 중..",
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
              body: CustomLoadingIndicator(
                message: "서비스 정보를 불러오는 중..",
              ),
            );
          } else if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ServiceLogResponse serviceLogResponse;
              if (snapshot.data == null)
                return;
              else
                serviceLogResponse = snapshot.data as ServiceLogResponse;
              if (APIResponseStatus.serviceLogPhoneNumberFailure
                  .isEqualTo(serviceLogResponse.status)) {
                // 서비스 로그 불러오기 실패
                print("서비스 로그 불러오기 실패, 재로그인 필요 : OnboardingScreen() 호출");
                context.go('/onboarding');
              } else {
                if (serviceLogResponse.userLogs.isEmpty) {
                  // 서비스 로그 없음
                  print("서비스 로그 없음, MainScreen() 호출");
                  context.go('/main');
                } else {
                  // 서비스 로그 불러오기 성공. 나열 시작
                  print(
                      "서비스 로그 불러오기 성공 : ${serviceLogResponse.userLogs.length}");
                  ref
                      .read(serviceLogProvider.notifier)
                      .reconnectWebsocketProvider(
                          serviceLogResponse.userLogs.last);
                  context.go('/main');
                }
              }
            });
          } else if (snapshot.hasError) {
            // 에러 처리
            print("에러 발생: ${snapshot.error}");
          } else {
            // 기본 상태 (로딩 중)
            print("서비스 정보 로딩 중");
          }
          return Scaffold(
            body: CustomLoadingIndicator(
              message: "서비스 정보 로딩 중..",
            ),
          );
        },
      );
    }
  }
}

Future<void> backgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 메시지 수신 처리
  _showNotification(message);
}

Future<void> initializeNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel', 'high_importance_notification',
          importance: Importance.max));

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (details) {
      // 액션 추가...
      print("onDidReceiveNotificationResponse: ${details.payload}");
    },
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // 포어그라운드에서 메시지 수신 처리
    _showNotification(message);
  });

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    // 앱이 종료된 상태에서 수신된 메시지 처리
    _showNotification(message);
    print("getInitialMessage: ${message.data['test_parameter1']}");
  }
}

void _showNotification(RemoteMessage message) {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['test_parameter1']);
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
