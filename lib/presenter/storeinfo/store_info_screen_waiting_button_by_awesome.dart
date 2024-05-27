import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/presenter/main_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../services/debug.services.dart';
import '../../services/network/https_services.dart';

final peopleNumberProvider = StateProvider<int>((ref) => 1);
final waitingSuccessDialogProvider = StateProvider<bool?>((ref) => null);

class WaitingButtonAwesome extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingButtonAwesome({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\nWaitingButtonAwesome build 진입");
    final numberOfPersonControlloer = ref.watch(peopleNumberProvider);
    final userInfo = ref.watch(userInfoProvider)?.phoneNumber;

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
              if (waitingState) {
                // 현재 웨이팅 중이므로 웨이팅 취소 dialog를 띄우고, 웨이팅 취소를 위한 로직을 실행한다.
                AwesomeDialogWidget.showCustomDialogWithCancel(
                  context: context,
                  title: '웨이팅 취소',
                  desc: '웨이팅을 취소하시겠습니까?',
                  dialogType: DialogType.warning,
                  onPressed: () {
                    // 웨이팅 취소 로직
                    ref
                        .read(storeWaitingRequestNotifierProvider.notifier)
                        .sendWaitingCancelRequest(storeCode, userInfo!);
                    ref
                        .read(storeWaitingUserCallNotifierProvider.notifier)
                        .unSubscribe();
                  },
                  btnText: '네',
                  onCancel: () {},
                  cancelText: '아니요',
                );
              } else {
                // 현재 웨이팅 중이 아니므로 웨이팅 시작 dialog를 띄우고, 웨이팅 시작을 위한 로직을 실행한다.
                AwesomeDialogWidget.showCustomDialogWithCancel(
                  context: context,
                  title: '웨이팅 시작',
                  desc: '웨이팅을 시작하시겠습니까?',
                  dialogType: DialogType.info,
                  onPressed: () async {
                    printd("waitingState: $waitingState");
                    // 웨이팅 시작 로직
                    await subscribeAndShowDialog(context, storeCode, userInfo!,
                            numberOfPersonControlloer.toString(), ref)
                        .then((value) {
                      if (value == APIResponseStatus.success ||
                          value == APIResponseStatus.waitingAlreadyJoin) {
                        printd("웨이팅 성공");
                        context.pop();
                        ref.read(selectedIndexProvider.notifier).state = 2;
                      } else {
                        printd("웨이팅 실패");
                        AwesomeDialogWidget.showCustomDialog(
                          context: context,
                          title: '웨이팅 실패',
                          desc: '다시 시도해주세요.',
                          dialogType: DialogType.error,
                          onPressed: () {},
                          btnText: '확인',
                        );
                      }
                    });
                  },
                  btnText: '시작',
                  onCancel: () {},
                  cancelText: '취소',
                  body: Consumer(builder: (context, ref, child) {
                    final numberOfPersonControlloer =
                        ref.watch(peopleNumberProvider);
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFFFFB74D), width: 2),
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
                );
              }
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

  Future<APIResponseStatus> subscribeAndShowDialog(
      BuildContext context,
      int storeCode,
      String phoneNumber,
      String numberOfPersons,
      WidgetRef ref) async {
    // 스트림 구독
    print("subscribeAndShowDialog");

    final waitingResult = await ref
        .read(storeWaitingRequestNotifierProvider.notifier)
        .subscribeToStoreWaitingRequest(
            storeCode, phoneNumber, int.parse(numberOfPersons));

    printd("웨이팅 성공 여부: $waitingResult");
    // 웨이팅 성공 여부에 따라
    if (waitingResult == APIResponseStatus.success ||
        waitingResult == APIResponseStatus.waitingAlreadyJoin) {
      // 성공했다면 전화번호가 포함된 링크로 이동
      await Future.delayed(Duration.zero, () {
        if (waitingResult == APIResponseStatus.success) {
          ref.read(waitingSuccessDialogProvider.notifier).state = true;
        } else {
          ref.read(waitingSuccessDialogProvider.notifier).state = false;
        }
        // ref.read(streamActiveProvider.notifier).state = false;
        // ref.read(storeDetailInfoProvider.notifier).clearStoreDetailInfo();
        // ref.read(storeWaitingInfoNotifierProvider.notifier).clearWaitingInfo();
      });
    }

    return waitingResult;
  }
}
