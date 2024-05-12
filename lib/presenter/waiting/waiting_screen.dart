import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/network/https/post_store_info_future_provider.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:orre/widget/text_field/text_input_widget.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../storeinfo/store_info_screen.dart';

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

    print("listOfWaitingStoreProvider: ${listOfWaitingStoreProvider}");

    return Scaffold(
      appBar: AppBar(
        title: TextWidget('줄서기 진행 중인 가게'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(storeWaitingRequestNotifierProvider.notifier)
                  .clearWaitingRequestList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          final item = listOfWaitingStoreProvider;
          if (item == null) {
            return ListTile(
              title: TextWidget('줄서기 중인 가게가 없습니다.'),
            );
          } else {
            return WaitingStoreItem(item);
          }
        },
      ),
    );
  }
}

class WaitingStoreItem extends ConsumerWidget {
  final StoreWaitingRequest storeWaitingRequest;

  WaitingStoreItem(this.storeWaitingRequest);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeDetailAsyncValue =
        ref.watch(storeDetailProvider(storeWaitingRequest.token.storeCode));
    final phoneNumberTextController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => StoreDetailInfoWidget(
                  storeCode: storeWaitingRequest.token.storeCode))),
      child: Form(
        key: _formKey,
        child: ListTile(
          leading: Icon(Icons.store),
          title: storeDetailAsyncValue.when(
              data: (data) => TextWidget(data.storeName), // 가게 이름 동적으로 표시
              loading: () => TextWidget('가게 정보 불러오는 중...'),
              error: (e, _) => TextWidget('가게 정보를 불러올 수 없습니다.')),
          subtitle: TextWidget(
              'Waiting Number: ${storeWaitingRequest.token.waiting}'),
          trailing: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: TextWidget('웨이팅 취소'),
                content: TextInputWidget(
                  controller: phoneNumberTextController,
                  hintText: '전화번호 입력',
                  type: TextInputType.number,
                  ref: ref,
                  autofillHints: [AutofillHints.telephoneNumber],
                  isObscure: false,
                  minLength: 11,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: TextWidget('취소'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: TextWidget('확인'),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final enteredCode = phoneNumberTextController.text;
                      final phoneNumber = storeWaitingRequest.token.phoneNumber;
                      print("enteredCode: $enteredCode");
                      print("phoneNumber: $phoneNumber");

                      if (enteredCode == phoneNumber) {
                        ref
                            .read(storeWaitingRequestNotifierProvider.notifier)
                            .sendWaitingCancelRequest(
                                storeWaitingRequest.token.storeCode,
                                storeWaitingRequest.token.phoneNumber);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: TextWidget('전화번호가 일치하지 않습니다.')));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
