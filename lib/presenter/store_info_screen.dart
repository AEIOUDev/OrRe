import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/websocket/store_info_state_notifier.dart';

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
    ref.read(storeInfoProvider.notifier).sendStoreCode(widget.storeCode);
  }

  @override
  void dispose() {
    ref.read(storeInfoProvider.notifier).unSubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeInfoProvider);

    return Scaffold(
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
                  Text('가게 코드: ${storeDetailInfo.storeCode}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('가게 이름: ${storeDetailInfo.storeName}',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('대기중인 팀 수: ${storeDetailInfo.numberOfTeamsWaiting}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('예상 대기 시간: ${storeDetailInfo.estimatedWaitingTime}분',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 20),
                  Text('메뉴:', style: Theme.of(context).textTheme.bodyMedium),
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
                          subtitle:
                              Text('${menu['price']}원 - ${menu['introduce']}'),
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
    );
  }

  void _startWaiting() {
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
                decoration: InputDecoration(
                  labelText: "이름",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "전화번호",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "인원 수",
                ),
                keyboardType: TextInputType.number,
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
