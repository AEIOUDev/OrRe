import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/store_waiting_list_state_notifier.dart';

class WaitingInfoWidget extends ConsumerWidget {
  final int storeCode;

  WaitingInfoWidget({Key? key, required this.storeCode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // storeWaitingListProvider에서 상태를 구독합니다.
    final waitingInfos = ref.watch(storeWaitingListProvider);
    // 특정 storeCode에 해당하는 StoreWaitingInfo를 찾습니다.
    final waitingInfo = waitingInfos.firstWhere(
      (info) => info.storeCode == storeCode,
      orElse: () => StoreWaitingInfo(
        storeCode: 0,
        storeName: '정보 없음',
        storeInfoVersion: 0,
        numberOfTeamsWaiting: 0,
        estimatedWaitingTime: 0,
        menuInfo: null,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Some other UI parts', style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        // 특정 storeCode에 해당하는 정보를 표시합니다.
        Text('Store Name: ${waitingInfo.storeName}',
            style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        Text('Store Code: ${waitingInfo.storeCode}',
            style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        Text('Number of Teams Waiting: ${waitingInfo.numberOfTeamsWaiting}',
            style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text(
            'Estimated Waiting Time: ${waitingInfo.estimatedWaitingTime} minutes',
            style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
