import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/main.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/homescreen/setting_screen.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug.services.dart';

class HomeScreenAppBar extends ConsumerWidget {
  final LocationInfo location;

  const HomeScreenAppBar({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        height: 300,
        color: Colors.transparent,
        child: AppBar(
          title: GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(location.locationName),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            onTap: () {
              context.push('/location/locationManagement');
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {
                // 가게 검색 로직
                printd("임시로 Store Info 1로 이동");
                context.push('/storeinfo/1');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.star,
                color: Colors.black,
              ),
              onPressed: () {
                print("즐겨찾기 페이지로 이동");
                // 즐겨찾기 페이지로 이동
                showNotification();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                // 설정 페이지로 이동
                context.push("/setting");
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Color(0xFFFFB74D),
        ));
  }

  void showNotification() async {
    var androidDetails = AndroidNotificationDetails(
      '유니크한 알림 채널 ID',
      '알림종류 설명',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 0, 0),
    );

    var iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // 알림 id, 제목, 내용 맘대로 채우기
    notifications.show(1, '제목1', '내용1',
        NotificationDetails(android: androidDetails, iOS: iosDetails));
  }
}
