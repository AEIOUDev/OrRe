import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/debug.services.dart';

class PermissionRequestLocationScreen extends ConsumerStatefulWidget {
  @override
  _PermissionRequestLocationScreenState createState() =>
      _PermissionRequestLocationScreenState();
}

class _PermissionRequestLocationScreenState
    extends ConsumerState<PermissionRequestLocationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Location permission granted, do something
      print("Location permission granted");
    } else if (status.isDenied) {
      // Location permission denied, show error message or handle accordingly
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      // Location permission permanently denied, show error message or handle accordingly
      print("Location permission permanently denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    printd("PermissionRequestLocationScreen build");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget("위치 권한이 필요한 이유 안내하는 내용"),
            SizedBox(height: 16),
            SmallButtonWidget(
              text: "권한 부여하기",
              onPressed: () {
                openAppSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
