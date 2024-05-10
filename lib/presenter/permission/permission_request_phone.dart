import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestPhoneScreen extends ConsumerStatefulWidget {
  @override
  _PermissionRequestPhoneScreenState createState() =>
      _PermissionRequestPhoneScreenState();
}

class _PermissionRequestPhoneScreenState
    extends ConsumerState<PermissionRequestPhoneScreen> {
  @override
  void initState() {
    super.initState();
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
