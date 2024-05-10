import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    print("WaitingStatusWidget");
    print("storeCode: $storeCode");
    final storeWaitingInfo = ref
        .watch(storeWaitingInfoNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .first;
    storeWaitingInfo.waitingTeamList.forEach((element) {
      print("waitingTeamList: $element");
    });
    final myUserCall = ref
        .watch(storeWaitingUserCallNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .firstOrNull;
    final remaingTime = ref.watch(waitingUserCallTimeListProvider);

    if (myWaitingInfo != null) {
      final myWaitingNumber = myWaitingInfo!.token.waiting;
      print("myWaitingNumber" + {myWaitingNumber}.toString());
      final int myWaitingIndex = storeWaitingInfo.waitingTeamList
          .indexWhere((team) => team == myWaitingNumber);
      print("myWaitingIndex" + {myWaitingIndex}.toString());
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(storeCode, myWaitingNumber);
      if (myUserCall != null) {
        final enteringTime = myUserCall.entryTime;
        print("enteringTime" + {enteringTime}.toString());
        print("nowTime" + {DateTime.now()}.toString());

        return SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget('내 웨이팅 번호: ${myWaitingInfo?.token.waiting}'),
              TextWidget('남은 팀 수 :  ${myWaitingIndex.toString()}'),
              TextWidget('남은 입장 시간: ${remaingTime.inSeconds}초'),
            ],
          ),
        );
      } else {
        // if (myWaitingIndex == -1) {
        //   return SliverToBoxAdapter(
        //     child: Container(
        //       height: 50,
        //       width: 50,
        //       alignment: Alignment.center,
        //       child: CircularProgressIndicator(
        //         color: Colors.orange,
        //       ),
        //     ),
        //   );
        // } else {
        return SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget('내 웨이팅 번호: ${myWaitingInfo?.token.waiting}'),
              TextWidget('남은 팀 수 :  ${myWaitingIndex.toString()}'),
              TextWidget(
                  '예상 대기 시간: ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
            ],
          ),
        );
      }
    } else {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            TextWidget('대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}'),
            TextWidget(
                '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
            Divider(),
          ],
        ),
      );
    }
  }
}
