import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/websocket/store_waiting_info_list_state_notifier.dart';
import '../provider/websocket/store_info_state_notifier.dart';
import '../provider/websocket/store_waiting_info_request_state_notifier.dart';

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
    final storeWaitingInfo = ref
        .watch(storeWaitingInfoNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == widget.storeCode)))
        .first;

    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          print('didPop: $didPop');
          if (didPop) {
            ref.read(storeInfoProvider.notifier).unSubscribe();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(storeDetailInfo?.storeName ?? '가게 이름을 불러오는 중...'),
          ),
          body: storeDetailInfo == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(storeDetailInfo.storeImageMain),
                      Text('가게 코드: ${storeDetailInfo.storeCode}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('가게 이름: ${storeDetailInfo.storeName}',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('가게 소개: ${storeDetailInfo.storeIntroduce}'),
                      Text('가게 카테고리: ${storeDetailInfo.storeCategory}'),
                      Text(
                          '대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                          '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분',
                          style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 20),
                      Text('메뉴:',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Expanded(
                        child: ListView.builder(
                          itemCount: storeDetailInfo.menuInfo.length,
                          itemBuilder: (context, index) {
                            final menu = storeDetailInfo.menuInfo[index];
                            return ListTile(
                              leading: menu['img'] != null
                                  ? Image.network(menu['img'],
                                      width: 50, height: 50)
                                  : null,
                              title: Text(menu['menu']),
                              subtitle: Text(
                                  '${menu['price']}원 - ${menu['introduce']}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _startWaiting,
            tooltip: '웨이팅 시작',
            child: Icon(Icons.add),
          ),
        ));
  }

  void _startWaiting() {
    final phoneNumberController = TextEditingController();
    final numberOfPersonControlloer = TextEditingController();

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
                print("가게 코드: ${widget.storeCode}");
                print("웨이팅 시작");
                ref
                    .read(storeWaitingRequestNotifierProvider.notifier)
                    .subscribeToStoreWaitingRequest(
                      widget.storeCode,
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
}
