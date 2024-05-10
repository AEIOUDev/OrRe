import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/error/network_error_screen.dart';
import 'package:orre/presenter/error/websocket_error_screen.dart';
import 'package:orre/presenter/main_screen.dart';
import 'package:orre/presenter/permission/permission_request_location.dart';
import 'package:orre/presenter/permission/permission_request_phone.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class ErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorStateNotifierProvider);

    print("ErrorScreen");
    error.forEach((element) {
      print(element);
    });

    if (error.isEmpty) {
      return Scaffold(
        body: Center(
          child: MainScreen(),
        ),
      );
    }

    switch (error.last) {
      case Error.websocket:
        return WebsocketErrorScreen();
      case Error.network:
        return NetworkErrorScreen();
      case Error.locationPermission:
        return PermissionRequestLocationScreen();
      case Error.callPermission:
        return PermissionRequestPhoneScreen();
      default:
        return Scaffold(
          body: Center(
            child: TextWidget('알 수 없는 오류가 발생했습니다.'),
          ),
        );
    }
  }
}
