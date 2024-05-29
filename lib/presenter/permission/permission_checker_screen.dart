import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import '../../services/debug.services.dart';
import '../../widget/button/big_button_widget.dart';
import '../../widget/text/text_widget.dart';

class PermissionCheckerScreen extends ConsumerStatefulWidget {
  @override
  _PermissionCheckerScreenState createState() =>
      _PermissionCheckerScreenState();
}

class _PermissionCheckerScreenState
    extends ConsumerState<PermissionCheckerScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    List<Permission> permissions = [
      Permission.notification,
      Permission.location,
    ];

    // iOS가 아닐 경우에만 전화 권한 추가
    if (!Platform.isIOS) {
      permissions.add(Permission.phone);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    List<String> deniedPermissions = [];

    statuses.forEach((permission, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        String permissionName;
        switch (permission) {
          case Permission.phone:
            permissionName = "전화";
            break;
          case Permission.notification:
            permissionName = "알림";
            break;
          case Permission.location:
            permissionName = "위치";
            break;
          default:
            permissionName = "알 수 없는 권한";
        }
        deniedPermissions.add(permissionName);
      }
    });

    if (deniedPermissions.isNotEmpty) {
      setState(() {});
    } else {
      // 모든 권한이 허용되면 다음 페이지로 이동
      printd("이동!");
      context.go('/initial');
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    List<Permission> permissions = [
      Permission.notification,
      Permission.location,
    ];

    // iOS가 아닐 경우에만 전화 권한 추가
    if (!Platform.isIOS) {
      permissions.add(Permission.phone);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    List<String> deniedPermissions = [];

    statuses.forEach((permission, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        String permissionName;
        switch (permission) {
          case Permission.phone:
            permissionName = "전화";
            break;
          case Permission.notification:
            permissionName = "알림";
            break;
          case Permission.location:
            permissionName = "위치";
            break;
          default:
            permissionName = "알 수 없는 권한";
        }
        deniedPermissions.add(permissionName);
      }
    });

    if (deniedPermissions.isNotEmpty) {
      _showPermissionDeniedDialog(context, deniedPermissions);
    } else {
      // 모든 권한이 허용되면 다음 페이지로 이동
      printd("이동!");
      context.go('/initial');
    }
  }

  void _showPermissionDeniedDialog(
      BuildContext context, List<String> deniedPermissions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('권한 허용 필요'),
          content: Text(
              '다음 권한들이 허용되지 않았습니다: ${deniedPermissions.join(', ')}.\n모든 권한을 허용해야 다음 단계로 진행할 수 있습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            TextWidget(
              "오리",
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBF52),
            ),
            SizedBox(height: 20),
            TextWidget(
              "오리의 이용을 위해\n아래 권한을 허용해 주세요.",
              textAlign: TextAlign.center,
              fontSize: 16,
              color: Colors.black,
              maxLines: 5,
            ),
            SizedBox(height: 40),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 20),
            PermissionItem(
              icon: Icons.phone,
              title: "전화",
              description:
                  "오디오북 또는 TTS(텍스트 음성변환) 모든 이용 도중 다른\n미디어 앱 사용시 음성 제어를 위해 필요한 권한이 필요합니다.",
            ),
            PermissionItem(
              icon: Icons.notifications,
              title: "알림",
              description: "중요 알림을 받고 빠른 응답을 할 수 있도록 알림 권한이 필요합니다.",
            ),
            PermissionItem(
              icon: Icons.location_on,
              title: "위치",
              description: "현재 위치를 확인하고 맞춤형 서비스를 제공하기 위해 위치 권한이 필요합니다.",
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: BigButtonWidget(
                text: "권한 설정하기",
                onPressed: () async {
                  await _requestPermissions(context);
                },
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  PermissionItem(
      {required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          SizedBox(width: 20),
          Container(
            width: 1.sw - 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(title, fontSize: 18, fontWeight: FontWeight.bold),
                SizedBox(height: 5),
                TextWidget(
                  description,
                  fontSize: 14,
                  color: Colors.grey,
                  maxLines: 5,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
