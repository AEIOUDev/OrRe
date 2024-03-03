import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presenter/reservation.dart';
import 'presenter/store_waiting_widget.dart';

void main() {
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
              // builder: (context) => ReservationPage(storeCode: storeCode));
              builder: (context) => WaitingInfoWidget(storeCode: storeCode));
        }

        // 다른 경로는 여기에서 처리
        // 기본적으로 홈페이지로 리다이렉트
        return MaterialPageRoute(builder: (context) => HomePage());
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Text("Welcome to the Home Page"),
      ),
    );
  }
}
