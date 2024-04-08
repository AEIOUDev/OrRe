import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orre/provider/websocket/store_waiting_info_list_state_notifier.dart';
import '../provider/waiting_usercall_time_list_state_notifier.dart';
import '../provider/websocket/store_info_state_notifier.dart';
import '../provider/websocket/store_waiting_info_request_state_notifier.dart';
import '../provider/websocket/store_waiting_usercall_list_state_notifier.dart';

class StoreDetailInfoWidget extends ConsumerStatefulWidget {
  final int storeCode;

  StoreDetailInfoWidget({Key? key, required this.storeCode}) : super(key: key);

  @override
  _StoreDetailInfoWidgetState createState() => _StoreDetailInfoWidgetState();
}

class _StoreDetailInfoWidgetState extends ConsumerState<StoreDetailInfoWidget> {
  @override
  void initState() {
    super.initState();
    print('storeCode: ${widget.storeCode}');
    ref.read(storeInfoProvider.notifier).subscribeToStoreInfo(widget.storeCode);
    ref
        .read(storeWaitingInfoNotifierProvider.notifier)
        .subscribeToStoreWaitingInfo(widget.storeCode);
  }

  // @override
  // void dispose() {
  //   ref.read(storeInfoProvider.notifier).unSubscribe();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeInfoProvider);
    // final storeWaitingInfo = ref
    //     .watch(storeWaitingInfoNotifierProvider.select((value) =>
    //         value.where((element) => element.storeCode == widget.storeCode)))
    //     .first;

    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider.select(
        (value) => value
            .where((element) =>
                element.waitingDetails.storeCode == storeDetailInfo!.storeCode)
            .firstOrNull));
    final nowWaiting = myWaitingInfo != null;
    print(nowWaiting);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        print('didPop: $didPop');
        if (didPop) {
          ref.read(storeInfoProvider.notifier).unSubscribe();
        }
      },
      child: Scaffold(
          body: storeDetailInfo == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StoreBannerAppBar(storeDetailInfo),
                      WaitingStatusWidget(
                          storeCode: storeDetailInfo.storeCode,
                          myWaitingInfo: myWaitingInfo),
                      Divider(),
                      StoreMenuListWidget(storeDetailInfo: storeDetailInfo),
                      Divider(),
                    ],
                  ),
                ),
          floatingActionButton: storeDetailInfo != null
              ? WaitingButton(
                  storeCode: storeDetailInfo.storeCode,
                  waitingState: nowWaiting,
                )
              : null,
          bottomNavigationBar: SizedBox(
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          )),
    );
  }
}

class StoreBannerAppBar extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreBannerAppBar(this.storeDetailInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 350,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 350,
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    storeDetailInfo.storeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        storeDetailInfo.storeCategory,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(" | ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white)),
                      Text(
                        storeDetailInfo.storeIntroduce,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: ClipOval(
              child: Image.network(
                storeDetailInfo.storeImageMain,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final myUserCall = ref
        .watch(storeWaitingUserCallNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .firstOrNull;
    final remaingTime = ref.watch(waitingUserCallTimeListProvider);

    if (myWaitingInfo != null) {
      final myWaitingNumber = myWaitingInfo!.waitingDetails.waiting;
      final int myWaitingIndex = storeWaitingInfo.waitingTeamList
          .indexWhere((team) => team == myWaitingNumber);
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(storeCode, myWaitingNumber);
      if (myUserCall != null) {
        final enteringTime = myUserCall.entryTime;
        print("enteringTime" + {enteringTime}.toString());
        print("nowTime" + {DateTime.now()}.toString());

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('내 웨이팅 번호: ${myWaitingInfo?.waitingDetails.waiting}'),
            Text('남은 팀 수 :  ${myWaitingIndex.toString()}'),
            Text('남은 입장 시간: ${remaingTime.inSeconds}초'),
          ],
        );
      } else {
        if (myWaitingIndex == -1) {
          return Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('내 웨이팅 번호: ${myWaitingInfo?.waitingDetails.waiting}'),
              Text('남은 팀 수 :  ${myWaitingIndex.toString()}'),
              Text(
                  '예상 대기 시간: ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
            ],
          );
        }
      }
    } else {
      return Column(
        children: [
          Text('대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}'),
          Text(
              '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
          Divider(),
        ],
      );
    }
  }
}

class StoreMenuListWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreMenuListWidget({required this.storeDetailInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storeDetailInfo.menuInfo.length < 1) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 50),
            Text('메뉴 정보가 없습니다.'),
          ],
        ),
      );
    } else {
      return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: storeDetailInfo.menuInfo.length,
          itemBuilder: (context, index) {
            final menu = storeDetailInfo.menuInfo[index];
            return ListTile(
              leading: menu['img'] != null
                  ? Image.network(menu['img'], width: 50, height: 50)
                  : null,
              title: Text(menu['menu']),
              subtitle: Text('${menu['price']}원 - ${menu['introduce']}'),
            );
          },
          separatorBuilder: (context, index) => Divider() // 구분선 추가,
          );
    }
  }
}

class WaitingButton extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingButton({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
        onPressed: () {
          final phoneNumberController = TextEditingController();
          final numberOfPersonControlloer = TextEditingController();

          print("waitingState" + {waitingState}.toString());
          if (waitingState) {
            // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
            final waitingInfo = ref.watch(
                storeWaitingRequestNotifierProvider.select((value) => value
                    .where((element) =>
                        element.waitingDetails.storeCode == storeCode)
                    .firstOrNull));

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("웨이팅 취소"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: "전화번호",
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text("취소"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("확인"),
                      onPressed: () {
                        // 여기에서 입력된 정보를 처리합니다.
                        // 예를 들어, 웨이팅 취소 요청을 서버에 보내는 로직을 구현할 수 있습니다.
                        print("전화번호: ${phoneNumberController.text}");
                        print("가게 코드: $storeCode");
                        print("웨이팅 취소");
                        ref
                            .read(storeWaitingRequestNotifierProvider.notifier)
                            .subscribeToStoreWaitingCancleRequest(
                              storeCode,
                              phoneNumberController.text,
                            );
                        ref
                            .read(storeWaitingUserCallNotifierProvider.notifier)
                            .unSubscribe(
                                storeCode, waitingInfo!.waitingDetails.waiting);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            // 웨이팅 시작을 위한 정보 입력 다이얼로그 표시
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("웨이팅 시작"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: "전화번호",
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: numberOfPersonControlloer,
                        decoration: InputDecoration(
                          labelText: "인원 수",
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text("취소"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("확인"),
                      onPressed: () {
                        // 여기에서 입력된 정보를 처리합니다.
                        // 예를 들어, 웨이팅 요청을 서버에 보내는 로직을 구현할 수 있습니다.
                        print("전화번호: ${phoneNumberController.text}");
                        print("인원 수: ${numberOfPersonControlloer.text}");
                        print("가게 코드: $storeCode");
                        print("웨이팅 시작");
                        ref
                            .read(storeWaitingRequestNotifierProvider.notifier)
                            .subscribeToStoreWaitingRequest(
                              storeCode,
                              phoneNumberController.text,
                              int.parse(numberOfPersonControlloer.text),
                            );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        tooltip: waitingState ? '웨이팅 시작' : '웨이팅 취소',
        child: waitingState
            ? Icon(Icons.person_remove_alt_1)
            : Icon(Icons.person_add_alt_1));
  }
}
