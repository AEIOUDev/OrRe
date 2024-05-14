import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:orre/widget/text_field/text_input_widget.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';

final peopleNumberProvider = StateProvider<int>((ref) => 1);

final waitingFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final waitingPhoneNumberProvider = StateProvider<TextEditingController>((ref) {
  final userInfo = ref.watch(userInfoProvider);
  final phoneNumberController = TextEditingController();
  phoneNumberController.text = userInfo?.phoneNumber ?? "";
  return phoneNumberController;
});

class WaitingDialog extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingDialog({required this.storeCode, required this.waitingState});

  // 웨이팅 시작을 위한 정보 입력 다이얼로그 표시
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumberController = ref.watch(waitingPhoneNumberProvider);
    final numberOfPersonControlloer = ref.watch(peopleNumberProvider);

    final formKey = ref.watch(waitingFormKeyProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 모서리를 직각으로 설정
      ),
      backgroundColor: Colors.white,
      title: TextWidget("웨이팅 시작"),
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
            SizedBox(height: 16),
            Consumer(builder: (context, ref, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Color(0xFFFFB74D),
                    ),
                    onPressed: () {
                      if (numberOfPersonControlloer > 1) {
                        ref.read(peopleNumberProvider.notifier).state--;
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFFFB74D), width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AnimatedFlipCounter(
                      value: numberOfPersonControlloer,
                      suffix: "명",
                      textStyle: TextStyle(
                        fontFamily: 'Dovemayo_gothic',
                        fontSize: 36,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Color(0xFFFFB74D),
                    ),
                    onPressed: () {
                      ref.read(peopleNumberProvider.notifier).state++;
                    },
                  ),
                ],
              );
            }),
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
              // 여기에서 입력된 정보를 처리합니다.
              // 예를 들어, 웨이팅 요청을 서버에 보내는 로직을 구현할 수 있습니다.
              print("전화번호: ${phoneNumberController.text}");
              print("인원 수: ${numberOfPersonControlloer}");
              print("가게 코드: $storeCode");
              print("웨이팅 시작");
              subscribeAndShowDialog(
                  context,
                  storeCode,
                  phoneNumberController.text,
                  numberOfPersonControlloer.toString(),
                  ref);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void subscribeAndShowDialog(BuildContext context, int storeCode,
      String phoneNumber, String numberOfPersons, WidgetRef ref) {
    // 스트림 구독
    print("subscribeAndShowDialog");
    final stream =
        ref.watch(storeWaitingRequestNotifierProvider.notifier).startSubscribe(
              storeCode,
              phoneNumber,
              int.parse(numberOfPersons),
            );
    ref.read(storeWaitingRequestNotifierProvider.notifier).sendWaitingRequest(
          storeCode,
          phoneNumber,
          int.parse(numberOfPersons),
        );

    print("stream: $stream");
    // 스트림의 각 결과에 대해 다른 대화 상자를 표시
    stream.then((result) {
      print("result: $result");
      if (result) {
        final myWaitingInfo = ref.read(storeWaitingRequestNotifierProvider);
        ref
            .read(storeWaitingUserCallNotifierProvider.notifier)
            .subscribeToUserCall(storeCode, myWaitingInfo!.token.waiting);
        // 결과가 true 일 때의 대화 상자
        showDialog(
          context: context,
          builder: (context) => AlertPopupWidget(
            title: '웨이팅 성공',
            subtitle: '대기번호 ${myWaitingInfo.token.waiting}번으로 웨이팅 되었습니다.',
            buttonText: 'OK',
          ),
        );
      } else {
        // 결과가 false 일 때의 대화 상자
        showDialog(
          context: context,
          builder: (context) => AlertPopupWidget(
            title: '웨이팅 실패',
            subtitle: '잠시 후에 다시 시도해 주세요.',
            buttonText: '확인',
          ),
        );
      }
    }, onError: (error) {
      // 스트림에서 에러 발생 시 처리
      print("waiting error: ${error}");
      showDialog(
        context: context,
        builder: (context) => AlertPopupWidget(
          title: '웨이팅 에러',
          subtitle: '잠시 후에 다시 시도해 주세요.',
          buttonText: '확인',
        ),
      );
    });
  }
}
