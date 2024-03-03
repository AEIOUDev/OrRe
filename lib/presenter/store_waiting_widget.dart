import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/store_waiting_state_notifier.dart';

class WaitingInfoWidget extends StatelessWidget {
  final String storeCode;

  WaitingInfoWidget({Key? key, required this.storeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 다른 UI 부분
        Text('Some other UI parts', style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        // Consumer를 사용하여 특정 부분만 리빌드되도록 함
        Consumer(
          builder: (context, ref, child) {
            final waitingInfoAsyncValue =
                ref.watch(storeWaitingInfoStreamProvider(storeCode));

            return waitingInfoAsyncValue.when(
              data: (waitingInfo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Store Code: ${waitingInfo.storeCode}',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text(
                      'Current Waiting Queue: ${waitingInfo.waitingQueue.join(', ')}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Last Waiting Number: ${waitingInfo.lastWaitingNumber}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                      'Predicted Waiting Time: ${waitingInfo.predictWaitingTime} minutes',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Error: $e')),
            );
          },
        ),
      ],
    );
  }
}
