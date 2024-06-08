import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/debug_services.dart';
import '../../services/nfc_services.dart';
import '../../services/notifications_services.dart';
import '../../widget/popup/awesome_dialog_widget.dart';

class OrderPrepareScreen extends ConsumerStatefulWidget {
  @override
  _OrderPrepareScreenState createState() => _OrderPrepareScreenState();
}

class _OrderPrepareScreenState extends ConsumerState<OrderPrepareScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) => startNFCScan(ref));
  // }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final _message = ref.watch(nfcScanMessageProvider);

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: TextWidget(
          '주문',
          fontSize: 20.sp,
          color: Colors.black,
        ),
        centerTitle: false,
        backgroundColor: Color(0xFFFFB74D),
        toolbarHeight: 58.h,
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.black,
              size: 20.sp,
            ),
            onPressed: () async {
              printd("즐겨찾기 페이지로 이동이지만 지금은 이스터에그");
              // 즐겨찾기 페이지로 이동
              final status = await Permission.notification.status;
              if (status.isDenied || status.isPermanentlyDenied) {
                AwesomeDialogWidget.showCustomDialogWithCancel(
                  context: context,
                  title: "위치 권한 없음!",
                  desc: "웨이팅 알림을 받으려면 알림 권한이 필요합니다.",
                  dialogType: DialogType.warning,
                  onPressed: () async {
                    openAppSettings();
                  },
                  btnText: "설정으로 이동",
                  onCancel: () {},
                  cancelText: "나중에",
                );
              } else {
                NotificationService.showNotification(
                    NotificationType.easteregg);
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
              size: 20.sp,
            ),
            onPressed: () {
              // 설정 페이지로 이동
              context.push("/setting");
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -45 * 3.14 / 180,
              child: Icon(
                Icons.phonelink_ring,
                size: 80,
                color: Color(0xFFDFDFDF),
              ),
            ),
            SizedBox(height: 32.h),
            TextWidget(
              // _message,
              "현재 버전에서는 가게 주문을 지원하지 않습니다.",
              textAlign: TextAlign.center,
              fontSize: 16.sp,
              color: Color(0xFFDFDFDF),
            )
          ],
        ),
      ),
    );
  }
}
