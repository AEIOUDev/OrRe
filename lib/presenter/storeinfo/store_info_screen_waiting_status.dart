import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/model/store_waiting_info_model.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../model/store_service_log_model.dart';
import '../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../provider/waiting_usercall_time_list_state_notifier.dart';
import '../../services/debug_services.dart';

class WaitingStatusWidget extends ConsumerStatefulWidget {
  final int storeCode;
  final StoreWaitingRequest? myWaitingInfo;
  final LocationInfo locationInfo;

  WaitingStatusWidget(
      {required this.storeCode,
      this.myWaitingInfo,
      required this.locationInfo});

  @override
  _WaitingStatusWidgetState createState() => _WaitingStatusWidgetState();
}

class _WaitingStatusWidgetState extends ConsumerState<WaitingStatusWidget> {
  @override
  void didChangeDependencies() {
    printd("\n\nWaitingStatusWidgetState 진입");
    super.didChangeDependencies();

    final storeWaitingInfo = ref.watch(storeWaitingInfoNotifierProvider);

    if (storeWaitingInfo.isEmpty) {
      printd("storeWaitingInfo가 비어있음");
      ref
          .read(storeWaitingInfoNotifierProvider.notifier)
          .subscribeToStoreWaitingInfo(widget.storeCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    printd("\n\nWaitingStatusWidget 진입");

    final allWaitingInfo = ref.watch(storeWaitingInfoNotifierProvider);
    if (allWaitingInfo.isEmpty) {
      return SliverToBoxAdapter(
        child: TextWidget('대기 중인 가게가 없습니다.'),
      );
    }
    final storeWaitingInfo = ref
        .read(storeWaitingInfoNotifierProvider.notifier)
        .getStoreWaitingInfo(widget.storeCode);
    storeWaitingInfo.waitingTeamList.forEach((element) {
      printd("waitingTeamList: $element");
    });

    final myUserCall = ref.watch(storeWaitingUserCallNotifierProvider);
    final remainingTime = ref.watch(waitingUserCallTimeListProvider);
    return SliverToBoxAdapter(
      child: (widget.myWaitingInfo != null &&
              widget.myWaitingInfo?.token.storeCode == widget.storeCode)
          ? buildMyWaitingStatus(widget.myWaitingInfo!, storeWaitingInfo,
              myUserCall, remainingTime)
          : buildGeneralWaitingStatus(storeWaitingInfo, ref),
    );
  }

  Widget buildMyWaitingStatus(
      StoreWaitingRequest myWaitingInfo,
      StoreWaitingInfo storeWaitingInfo,
      UserCall? myUserCall,
      Duration? remainingTime) {
    printd("\n\nbuildMyWaitingStatus 진입");
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
              '남은 팀 수',
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 3,
            child: AnimatedFlipCounter(
              mainAxisAlignment: MainAxisAlignment.start,
              prefix: ':  ',
              value: myWaitingIndex,
              suffix: ' 팀',
              textStyle: TextStyle(
                fontFamily: 'Dovemayo_gothic',
                fontSize: 20.sp,
              ),
            ),
            // TextWidget(
            //   ': $myWaitingIndex 팀',
            //   textAlign: TextAlign.start,
            // ),
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
              ':  $myWaitingNumber 번',
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
    ];

    printd("myUserCall: ${myUserCall?.entryTime.second}");
    printd("remainingTime: ${remainingTime?.inSeconds}");
    if (myUserCall != null &&
        remainingTime != null &&
        remainingTime.inSeconds != -1) {
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
              child: AnimatedFlipCounter(
                mainAxisAlignment: MainAxisAlignment.start,
                prefix: ':  ',
                value: remainingTime.inSeconds,
                suffix: ' 초',
                textStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20.sp,
                  color: Color(0xFFFFB74D),
                ),
              ),
              // TextWidget(
              //   ': ${remainingTime.inSeconds} 초',
              //   textAlign: TextAlign.start,
              //   color: Color(0xFFFFB74D),
              // ),
            )
          ],
        ),
      );
    } else if (ref.watch(waitingStatus) == StoreWaitingStatus.CALLED) {
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
                  '입장 시간이 지났습니다.',
                  textAlign: TextAlign.start,
                  color: Color(0xFFFFB74D),
                )),
            Expanded(
              flex: 3,
              child: TextWidget(
                '',
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
              child: AnimatedFlipCounter(
                mainAxisAlignment: MainAxisAlignment.start,
                prefix: ':  ',
                value: myWaitingIndex *
                    storeWaitingInfo.estimatedWaitingTimePerTeam,
                suffix: ' 분',
                textStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20.sp,
                ),
              ),
              // TextWidget(
              //   ': ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
              //   textAlign: TextAlign.start,
              // ),
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
    printd("\n\nbuildGeneralWaitingStatus 진입");
    final nowLocation = ref.watch(locationListProvider).selectedLocation;
    // String distance;
    int distanceInt = 0;
    if (nowLocation == null) {
      // distance = '위치 정보를 불러오는 중입니다.';
    } else {
      // distance = '${nowLocation - widget.locationInfo}m';
      distanceInt = nowLocation - widget.locationInfo;
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
              child: AnimatedFlipCounter(
                mainAxisAlignment: MainAxisAlignment.start,
                prefix: ':  ',
                value: storeWaitingInfo.waitingTeamList.length,
                suffix: ' 팀',
                textStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20.sp,
                ),
              ),
              // TextWidget(
              //   ':  ${storeWaitingInfo.waitingTeamList.length} 팀',
              //   textAlign: TextAlign.start,
              // ),
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
              child: AnimatedFlipCounter(
                mainAxisAlignment: MainAxisAlignment.start,
                prefix: ':  ',
                value: storeWaitingInfo.waitingTeamList.length *
                    storeWaitingInfo.estimatedWaitingTimePerTeam,
                suffix: ' 분',
                textStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20.sp,
                ),
              ),
              // TextWidget(
              //   ':  ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam} 분',
              //   textAlign: TextAlign.start,
              // ),
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
              child: AnimatedFlipCounter(
                mainAxisAlignment: MainAxisAlignment.start,
                prefix: ':  ',
                value: distanceInt,
                suffix: 'm',
                textStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 20.sp,
                ),
              ),
              // TextWidget(
              //   ':  ${distance}',
              //   textAlign: TextAlign.start,
              // ),
            )
          ],
        ),
      ],
    );
  }
}
