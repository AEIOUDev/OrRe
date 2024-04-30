import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/store_info_model.dart';
import '../provider/store_detail_info_state_notifier.dart';
import '../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../provider/waiting_usercall_time_list_state_notifier.dart';

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
    ref.read(storeDetailInfoProvider.notifier).fetchStoreDetailInfo(
          StoreInfoParams(widget.storeCode, 0),
        );
  }

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeDetailInfoProvider);
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider.select(
        (value) => value
            .where((element) =>
                element.waitingDetails.storeCode == widget.storeCode)
            .firstOrNull));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
      ),
      body: storeDetailInfo.storeCode == 0
          ? Center(child: CircularProgressIndicator()) // TODO: 추후 에러 페이지로 변경
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StoreBannerAppBar(storeDetailInfo),
                  Divider(),
                  WaitingStatusWidget(
                      storeCode: widget.storeCode,
                      myWaitingInfo: myWaitingInfo),
                  Divider(),
                  StoreMenuListWidget(storeDetailInfo: storeDetailInfo),
                  Divider(),
                ],
              ),
            ),
      floatingActionButton: storeDetailInfo != StoreDetailInfo.nullValue()
          ? WaitingButton(
              storeCode: widget.storeCode,
              waitingState: (myWaitingInfo != null),
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
      ),
    );
  }
}

class StoreBannerAppBar extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreBannerAppBar(this.storeDetailInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("storeDetailInfo" + {storeDetailInfo.storeName}.toString());
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.orange,
      child: Column(
        children: [
          CachedNetworkImage(
              imageUrl: storeDetailInfo.storeImageMain,
              imageBuilder: (context, imageProvider) => Container(
                    width: MediaQuery.of(context).size.height / 5,
                    height: MediaQuery.of(context).size.height / 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.store)),
          SizedBox(height: 8),
          Text(
            storeDetailInfo.storeName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 8),
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
              leading: CachedNetworkImage(
                imageUrl: menu.image,
                imageBuilder: (context, imageProvider) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.no_food),
              ),
              title: Text(menu.menu),
              subtitle: Text('${menu.price}원 - ${menu.introduce}'),
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
                        Navigator.of(context).pop();
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
