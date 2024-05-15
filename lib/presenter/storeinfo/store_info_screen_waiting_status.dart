import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/model/store_waiting_info_model.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../provider/waiting_usercall_time_list_state_notifier.dart';

class WaitingStatusWidget extends ConsumerWidget {
  final int storeCode;
  final StoreWaitingRequest? myWaitingInfo;
  final LocationInfo locationInfo;

  WaitingStatusWidget(
      {required this.storeCode,
      this.myWaitingInfo,
      required this.locationInfo});

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
      child:
          (myWaitingInfo != null && myWaitingInfo?.token.storeCode == storeCode)
              ? buildMyWaitingStatus(
                  myWaitingInfo!, storeWaitingInfo, myUserCall, remainingTime)
              : buildGeneralWaitingStatus(storeWaitingInfo, ref),
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
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.person)),
          Expanded(
              flex: 3,
              child: TextWidget(
                '현재 대기 팀 수',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 3,
            child: TextWidget(
              ': $myWaitingIndex 팀',
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.info_outline)),
          Expanded(
              flex: 3,
              child: TextWidget(
                '웨이팅 번호',
                textAlign: TextAlign.start,
              )),
          Expanded(
            flex: 3,
            child: TextWidget(
              ': $myWaitingNumber 번',
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
      // TextWidget('내 웨이팅 번호: $myWaitingNumber'),
      // TextWidget("내 웨이팅 인원: ${myWaitingInfo.token.personNumber}명"),
      // TextWidget('내 웨이팅 전화번호: ${myWaitingInfo.token.phoneNumber}'),
      // TextWidget('남은 팀 수 : $myWaitingIndex'),
    ];

    print("myUserCall: $myUserCall");
    if (myUserCall != null &&
        remainingTime != null &&
        remainingTime.inSeconds > 0) {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: Icon(
                  Icons.watch_later,
                  color: Color(0xFFFFB74D),
                )),
            Expanded(
                flex: 3,
                child: TextWidget(
                  '남은 입장 시간',
                  textAlign: TextAlign.start,
                  color: Color(0xFFFFB74D),
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ': ${remainingTime.inSeconds} 초',
                textAlign: TextAlign.start,
                color: Color(0xFFFFB74D),
              ),
            )
          ],
        ),
      );
    } else {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Icon(Icons.watch_later)),
            Expanded(
                flex: 3,
                child: TextWidget(
                  '예상 대기 시간',
                  textAlign: TextAlign.start,
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ': ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget buildGeneralWaitingStatus(
      StoreWaitingInfo storeWaitingInfo, WidgetRef ref) {
    final nowLocation = ref.watch(nowLocationProvider);
    String distance;
    if (nowLocation == null) {
      distance = '위치 정보를 불러오는 중입니다.';
    } else {
      distance = '${nowLocation - locationInfo}m';
    }

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Icon(Icons.person)),
            Expanded(
                flex: 3,
                child: TextWidget(
                  '현재 대기 팀 수',
                  textAlign: TextAlign.start,
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ':  ${storeWaitingInfo.waitingTeamList.length} 팀',
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Icon(Icons.watch_later)),
            Expanded(
                flex: 3,
                child: TextWidget(
                  '예상 대기 시간',
                  textAlign: TextAlign.start,
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ':  ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Icon(Icons.room)),
            Expanded(
                flex: 3,
                child: TextWidget(
                  '나와의 거리',
                  textAlign: TextAlign.start,
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                ':  ${distance}',
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
        Divider(
          color: Color(0xFFDFDFDF),
          thickness: 2,
          endIndent: 10,
          indent: 10,
        ),
      ],
    );
  }
}
