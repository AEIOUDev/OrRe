import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/storeinfo/store_info_screen_waiting_button.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/store_detail_info_state_notifier.dart';

class BottomButtonSelector extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  BottomButtonSelector({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowWaitable =
        ref.watch(storeDetailInfoProvider.notifier).isCanReserve();

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
                return AlertDialog(
                  title: TextWidget("예약 불가"),
                  content: TextWidget("현재 예약이 불가능한 시간입니다."),
                  actions: [
                    TextButton(
                      child: TextWidget("확인"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          label: TextWidget('예약 불가'));
    }
  }
}
