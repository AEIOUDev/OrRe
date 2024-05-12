import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_waiting_info_model.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../provider/waiting_usercall_time_list_state_notifier.dart';

class WaitingStatusWidget extends ConsumerWidget {
  final int storeCode;
  final StoreWaitingRequest? myWaitingInfo;

  WaitingStatusWidget({required this.storeCode, this.myWaitingInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeWaitingInfo = ref
        .watch(storeWaitingInfoNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .first;
    storeWaitingInfo.waitingTeamList.forEach((element) {
      print("waitingTeamList: $element");
    });
    final myUserCall = ref.watch(storeWaitingUserCallNotifierProvider);
    final remainingTime = ref.watch(waitingUserCallTimeListProvider);

    return SliverToBoxAdapter(
      child: myWaitingInfo != null
          ? buildMyWaitingStatus(
              myWaitingInfo!, storeWaitingInfo, myUserCall, remainingTime)
          : buildGeneralWaitingStatus(storeWaitingInfo),
    );
  }

  Widget buildMyWaitingStatus(
      StoreWaitingRequest myWaitingInfo,
      StoreWaitingInfo storeWaitingInfo,
      UserCall? myUserCall,
      Duration? remainingTime) {
    final myWaitingNumber = myWaitingInfo.token.waiting;
    final myWaitingIndex =
        storeWaitingInfo.waitingTeamList.indexOf(myWaitingNumber);

    List<Widget> children = [
      TextWidget('내 웨이팅 번호: $myWaitingNumber'),
      TextWidget("내 웨이팅 인원: ${myWaitingInfo.token.personNumber}명"),
      TextWidget('내 웨이팅 전화번호: ${myWaitingInfo.token.phoneNumber}'),
      TextWidget('남은 팀 수 : $myWaitingIndex'),
    ];

    print("myUserCall: $myUserCall");
    if (myUserCall != null &&
        remainingTime != null &&
        remainingTime.inSeconds > 0) {
      children.add(TextWidget('남은 입장 시간: ${remainingTime.inSeconds}초'));
    } else {
      children.add(TextWidget(
          '예상 대기 시간: ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam}분'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget buildGeneralWaitingStatus(StoreWaitingInfo storeWaitingInfo) {
    return Column(
      children: [
        TextWidget('대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}'),
        TextWidget(
            '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
        Divider(),
      ],
    );
  }
}
