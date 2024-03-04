import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presenter/reservation.dart';
import 'presenter/store_waiting_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notifications_services.dart'; // Firebase 초기화 옵션을 포함한 파일

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // 경로 이름 파싱
        Uri uri = Uri.parse(settings.name!);
        // '/reservation/{가게코드}' 경로 처리
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'reservation') {
          String storeCode = uri.pathSegments[1];
          return MaterialPageRoute(
              builder: (context) => WaitingInfoWidget(storeCode: storeCode));
        }
        // 다른 경로는 여기에서 처리
        // 기본적으로 홈페이지로 리다이렉트
        return MaterialPageRoute(builder: (context) => HomePage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String?> fcmToken;

  @override
  void initState() {
    super.initState();
    fcmToken =
        FirebaseMessaging.instance.getToken(); // Fetch the token asynchronously
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        // Use FutureBuilder to wait for the FCM token
        child: FutureBuilder<String?>(
          future: fcmToken,
          builder: (context, snapshot) {
            // Check if the future is complete and has data
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Text("FCM Token: ${snapshot.data}");
            } else if (snapshot.hasError) {
              return Text("Error fetching FCM Token");
            } else {
              // Show a loading indicator while waiting for the token
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
