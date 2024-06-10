import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

enum NotificationType {
  easteregg,
  waitingCancel,
  waitingSuccess,
  notification3,
}

extension NotificationTypeExtension on NotificationType {
  int get id {
    switch (this) {
      case NotificationType.easteregg:
        return 0;
      case NotificationType.waitingCancel:
        return 1;
      case NotificationType.waitingSuccess:
        return 2;
      case NotificationType.notification3:
        return 3;
    }
  }

  String get channelID {
    return this.id.toString();
  }

  String get channelDescription {
    switch (this) {
      case NotificationType.easteregg:
        return '오리';
      case NotificationType.waitingCancel:
        return '웨이팅 취소';
      case NotificationType.waitingSuccess:
        return '웨이팅 성공';
      case NotificationType.notification3:
        return '알림 3';
    }
  }

  String get title {
    switch (this) {
      case NotificationType.easteregg:
        return '오리';
      case NotificationType.waitingCancel:
        return '웨이팅 취소';
      case NotificationType.waitingSuccess:
        return '웨이팅 성공';
      case NotificationType.notification3:
        return '알림 3';
    }
  }

  String get body {
    switch (this) {
      case NotificationType.easteregg:
        return '오리가 귀엽죠?';
      case NotificationType.waitingCancel:
        return '웨이팅이 취소되었습니다.';
      case NotificationType.waitingSuccess:
        return '웨이팅을 시작했습니다.';
      case NotificationType.notification3:
        return '알림 3';
    }
  }
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> listenNotifications() async {
    FirebaseMessaging.onMessage.listen(_showFlutterNotification);
  }

  void _showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // Feel free to add UI according to your preference, I am just using a custom Toast.
    print(notification?.web);
  }

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken() ?? '';
  }

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  static void showNotification(
    NotificationType notification,
  ) async {
    var androidDetails = AndroidNotificationDetails(
      notification.channelID,
      notification.channelDescription,
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
    notifications.show(notification.id, notification.title, notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails));
  }
}
