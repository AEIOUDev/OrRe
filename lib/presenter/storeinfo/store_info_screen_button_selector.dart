import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/storeinfo/store_info_screen.dart';
import 'package:orre/presenter/storeinfo/store_info_screen_waiting_button.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/network/https/store_detail_info_state_notifier.dart';

class BottomButtonSelector extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  BottomButtonSelector({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowWaitable =
        ref.read(storeDetailInfoProvider.notifier).isCanReserve();
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);

    if (myWaitingInfo == null) {
      print("myWaitingInfo is null");
      // 현재 웨이팅 중이 아님
      if (nowWaitable) {
        return WaitingButton(storeCode: storeCode, waitingState: waitingState);
      } else {
        return FloatingActionButton.extended(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertPopupWidget(
                    title: "웨이팅 불가",
                    subtitle: "현재 가게가 예약이 불가능한 상태 입니다.",
                    buttonText: '확인',
                  );
                },
              );
            },
            label: TextWidget('예약 불가'));
      }
    } else {
      // 현재 웨이팅 중임
      print("myWaitingInfo is not null : ${myWaitingInfo.token.storeCode}");
      if (myWaitingInfo.token.storeCode == storeCode) {
        // 현재 웨이팅 중인 가게임
        print("myWaitingInfo: $myWaitingInfo");
        return WaitingButton(storeCode: storeCode, waitingState: waitingState);
      } else {
        // 다른 가게에서 웨이팅 중임
        return FloatingActionButton.extended(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertPopupWidget(
                    title: "웨이팅 불가",
                    subtitle: "현재 다른 매장에서 웨이팅 중 입니다.",
                    autoPop: false,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => StoreDetailInfoWidget(
                            storeCode: myWaitingInfo.token.storeCode,
                          ),
                        ),
                      );
                    },
                    buttonText: '해당 매장으로 이동',
                  );
                },
              );
            },
            label: TextWidget('중복 예약 불가'));
      }
    }
  }
}
