import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/presenter/storeinfo/store_info_screen_waiting_button_by_awesome.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

class BottomButtonSelector extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;
  final bool nowWaitable;

  BottomButtonSelector(
      {required this.storeCode,
      required this.waitingState,
      required this.nowWaitable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);

    if (myWaitingInfo == null) {
      print("myWaitingInfo is null");
      // 현재 웨이팅 중이 아님
      if (nowWaitable) {
        return WaitingButtonAwesome(
            storeCode: storeCode, waitingState: waitingState);
      } else {
        return Container(
          width: 1.sw,
          height: 70,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () {
                    AwesomeDialogWidget.showWarningDialog(
                        context: context,
                        title: '예약 불가',
                        desc: '현재 예약이 불가능한 가게입니다.');
                  },
                  label: TextWidget('예약 불가'))),
        );
      }
    } else {
      // 현재 웨이팅 중임
      print("myWaitingInfo is not null : ${myWaitingInfo.token.storeCode}");
      if (myWaitingInfo.token.storeCode == storeCode) {
        // 현재 웨이팅 중인 가게임
        print("myWaitingInfo: $myWaitingInfo");
        return WaitingButtonAwesome(
            storeCode: storeCode, waitingState: waitingState);
      } else {
        // 다른 가게에서 웨이팅 중임
        return Container(
          width: 1.sw,
          height: 70,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () {
                    AwesomeDialogWidget.showCustomDialog(
                      context: context,
                      title: '중복 예약 불가',
                      desc: '이미 다른 가게에서 웨이팅 중입니다.',
                      btnText: '해당 가게로 이동',
                      onPressed: () {
                        context.push(
                            '/storeinfo/${myWaitingInfo.token.storeCode}');
                      },
                      dialogType: DialogType.info,
                    );
                  },
                  label: TextWidget('중복 예약 불가'))),
        );
      }
    }
  }
}
