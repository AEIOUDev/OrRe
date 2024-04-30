import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/store_detail_info_state_notifier.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../store_info_screen.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  @override
  Widget build(BuildContext context) {
    print("!!!!!!!!!!!!!!!!!!!");
    final listOfWaitingStoreProvider =
        ref.watch(storeWaitingRequestNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('줄서기 진행 중인 목록')),
      body: ListView.builder(
        itemCount: listOfWaitingStoreProvider.length,
        itemBuilder: (context, index) {
          final item = listOfWaitingStoreProvider[index];

          return WaitingStoreItem(item);
        },
      ),
    );
  }
}

class WaitingStoreItem extends ConsumerWidget {
  final StoreWaitingRequest storeWaitingRequest;

  WaitingStoreItem(StoreWaitingRequest this.storeWaitingRequest);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("?????????????????????????????");
    print(storeWaitingRequest.waitingDetails.storeCode);
    final textField = TextEditingController();

    final storeInfo = ref.watch(storeDetailInfoProvider);
    String storeName = storeInfo.storeName;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => StoreDetailInfoWidget(
                  storeCode: storeWaitingRequest.waitingDetails.storeCode))),
      child: ListTile(
        leading: Icon(Icons.store),
        title: Text(storeName),
        subtitle: Text(
            'Waiting Number: ${storeWaitingRequest.waitingDetails.waiting}'),
        trailing: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('웨이팅 취소'),
              content: TextField(
                controller: textField,
                maxLength: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(hintText: '전화번호 뒷자리 4자리를 입력하세요'),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    final enteredCode = int.parse(textField.text);
                    // final phoneNumber =
                    //     item.userSimpleInfo.phoneNumber; // 접근 방법 수정
                    final phoneNumber =
                        storeWaitingRequest.waitingDetails.phoneNumber;
                    final lastFourDigits = int.parse(
                        phoneNumber.substring(phoneNumber.length - 4));

                    if (enteredCode == lastFourDigits) {
                      ref
                          .read(storeWaitingRequestNotifierProvider.notifier)
                          .subscribeToStoreWaitingCancleRequest(
                              storeWaitingRequest.waitingDetails.storeCode,
                              storeWaitingRequest.waitingDetails.phoneNumber);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('전화번호 뒷자리가 일치하지 않습니다.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
