import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:orre/widget/text_field/text_input_widget.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';

class WaitingCancleDialog extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingCancleDialog({required this.storeCode, required this.waitingState});

  // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
    final waitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    final phoneNumberController = TextEditingController();
    phoneNumberController.text = waitingInfo?.token.phoneNumber ?? "";
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: TextWidget("웨이팅 취소"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextInputWidget(
              hintText: "전화번호",
              controller: phoneNumberController,
              isObscure: false,
              type: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              minLength: 11,
              maxLength: 11,
              ref: ref,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: TextWidget("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: TextWidget("확인"),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              // 여기에서 입력된 정보를 처리합니다.
              // 예를 들어, 웨이팅 취소 요청을 서버에 보내는 로직을 구현할 수 있습니다.
              print("전화번호: ${phoneNumberController.text}");
              print("가게 코드: $storeCode");
              print("웨이팅 취소");
              ref
                  .read(storeWaitingRequestNotifierProvider.notifier)
                  .sendWaitingCancleRequest(
                      storeCode, phoneNumberController.text);

              if (waitingInfo != null) {
                print("waitingInfo != null" + {waitingInfo.status}.toString());
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertPopupWidget(
                        title: '웨이팅 취소',
                        subtitle: '웨이팅이 취소되었습니다.',
                        buttonText: '확인',
                      );
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertPopupWidget(
                        title: '웨이팅 취소',
                        subtitle: '웨이팅이 취소되지 않았습니다.',
                        buttonText: '확인',
                      );
                    });
              }
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
