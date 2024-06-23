import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/debug_services.dart';

class PermissionRequestPhoneScreen extends ConsumerStatefulWidget {
  @override
  _PermissionRequestPhoneScreenState createState() =>
      _PermissionRequestPhoneScreenState();
}

class _PermissionRequestPhoneScreenState
    extends ConsumerState<PermissionRequestPhoneScreen>
    with WidgetsBindingObserver {
  void requestPhonePermission() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      // Phone permission granted, do something
      printd("Phone permission granted");
      context.pop();
    } else if (status.isDenied) {
      // Phone permission denied, show error message or handle accordingly
      printd("Phone permission denied");
      // openAppSettings;
    } else if (status.isPermanentlyDenied) {
      // Phone permission permanently denied, show error message or handle accordingly
      printd("Phone permission permanently denied");
      // openAppSettings;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      requestPhonePermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget("전화 권한이 필요한 이유 안내하는 내용"),
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
