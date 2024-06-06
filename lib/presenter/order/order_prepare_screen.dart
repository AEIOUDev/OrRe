import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../services/nfc_services.dart';

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
      appBar:
          AppBar(title: TextWidget('주문하기'), backgroundColor: Color(0xFFFFB74D)),
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
