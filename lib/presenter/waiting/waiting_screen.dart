import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/store_waiting_request_state_notifier.dart';
import '../../services/nfc_services.dart';
import '../store_waiting_widget.dart';
import '../store_info_screen.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  @override
  Widget build(BuildContext context) {
    final listOfWaitingStoreProvider =
        ref.watch(storeWaitingListProvider.notifier).state;
    final textField = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('줄서기 진행 중인 목록')),
      body: ListView.builder(
        itemCount: listOfWaitingStoreProvider.length,
        itemBuilder: (context, index) {
          final item = listOfWaitingStoreProvider[index];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        StoreDetailInfoWidget(storeCode: item.storeCode))),
            child: ListTile(
              leading: Icon(Icons.store),
              title: Text(item.storeName),
              subtitle: Text('Waiting Number: ${item.numberOfTeamsWaiting}'),
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
                      decoration:
                          InputDecoration(hintText: '전화번호 뒷자리 4자리를 입력하세요'),
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
                          final phoneNumber = "01092566504";
                          final lastFourDigits = int.parse(
                              phoneNumber.substring(phoneNumber.length - 4));

                          if (enteredCode == lastFourDigits) {
                            ref
                                .read(storeWaitingListProvider.notifier)
                                .removeWaiting(item);
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
        },
      ),
    );
  }
}
