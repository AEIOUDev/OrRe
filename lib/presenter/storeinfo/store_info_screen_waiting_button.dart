import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';

import 'store_info_screen_waiting_cancle_dialog.dart';
import 'store_info_screen_waiting_dialog.dart';

class WaitingButton extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingButton({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          print("waitingState" + {waitingState}.toString());
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return waitingState
                  ? WaitingCancleDialog(
                      storeCode: storeCode, waitingState: waitingState)
                  : WaitingDialog(
                      storeCode: storeCode,
                      waitingState: waitingState,
                    );
            },
          );
        },
        label: waitingState
            ? Row(
                children: [
                  Icon(Icons.person_remove_alt_1),
                  SizedBox(width: 8),
                  TextWidget('웨이팅 취소'),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  TextWidget('웨이팅 시작'),
                ],
              ));
  }
}
