import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/store_info_state_notifier.dart';

class StoreDetailInfoWidget extends ConsumerStatefulWidget {
  final String storeCode;

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
    );
  }
}
