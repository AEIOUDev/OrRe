import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';

import 'store_info_screen_waiting_cancel_dialog.dart';
import 'store_info_screen_waiting_dialog.dart';

class WaitingButton extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingButton({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 70,
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            backgroundColor: Color(0xFFFFB74D),
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
                      ? WaitingCancelDialog(
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
                      TextWidget(
                        '웨이팅 취소',
                        color: Colors.white,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 8),
                      TextWidget(
                        '웨이팅 시작',
                        color: Colors.white,
                      ),
                    ],
                  )),
      ),
    );
  }
}
