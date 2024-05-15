import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/network/https/post_store_info_future_provider.dart';
import 'package:orre/widget/button/big_button_widget.dart';
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
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          backgroundColor: Color(0xFFDFDFDF),
          title: TextWidget(' '),
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
        body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70.0),
                    topRight: Radius.circular(70.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    TextWidget(
                      '웨이팅 목록',
                      fontSize: 42,
                      color: Color(0xFFFFB74D),
                    ),
                    Divider(
                      color: Color(0xFFFFB74D),
                      thickness: 3,
                      endIndent: MediaQuery.of(context).size.width * 0.25,
                      indent: MediaQuery.of(context).size.width * 0.25,
                    ),
                    SizedBox(height: 25),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, irndex) {
                          final item = listOfWaitingStoreProvider;
                          if (item == null) {
                            return ListTile(
                              title: TextWidget(
                                '줄서기 중인 가게가 없습니다.',
                                color: Color(0xFFDFDFDF),
                              ),
                            );
                          } else {
                            return WaitingStoreItem(item);
                          }
                        },
                      ),
                    )
                  ],
                ))));
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
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TODO : 이거 가게 이미지로 못 바꿈??
                  Icon(
                    Icons.store,
                    size: 80,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      storeDetailAsyncValue.when(
                          data: (data) => TextWidget(
                                data.storeName,
                                textAlign: TextAlign.start,
                                fontSize: 28,
                              ), // 가게 이름 동적으로 표시
                          loading: () => TextWidget('가게 정보 불러오는 중...'),
                          error: (e, _) => TextWidget('가게 정보를 불러올 수 없습니다.')),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          TextWidget('내 웨이팅 번호는 ', fontSize: 20),
                          TextWidget(
                            '${storeWaitingRequest.token.waiting}',
                            fontSize: 24,
                            color: Color(0xFFDD0000),
                          ),
                          TextWidget('번 이예요.', fontSize: 20),
                        ],
                      ),
                      // TODO : 엄마 나 여기 몇 팀 남았는지 표시해줘.
                      Row(
                        children: [
                          TextWidget('내 순서까지 ', fontSize: 20),
                          TextWidget(
                            '14',
                            fontSize: 24,
                            color: Color(0xFFDD0000),
                          ),
                          TextWidget('팀이 남았어요.', fontSize: 20),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              BigButtonWidget(
                text: '웨이팅 취소하기',
                textColor: Color(0xFF999999),
                backgroundColor: Color(0xFFDFDFDF),
                minimumSize: Size(double.infinity, 40),
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
                          final phoneNumber =
                              storeWaitingRequest.token.phoneNumber;
                          print("enteredCode: $enteredCode");
                          print("phoneNumber: $phoneNumber");

                          if (enteredCode == phoneNumber) {
                            ref
                                .read(storeWaitingRequestNotifierProvider
                                    .notifier)
                                .sendWaitingCancelRequest(
                                    storeWaitingRequest.token.storeCode,
                                    storeWaitingRequest.token.phoneNumber);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: TextWidget('전화번호가 일치하지 않습니다.')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // leading: Icon(Icons.store),
        //   subtitle: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       storeDetailAsyncValue.when(
        //           data: (data) => TextWidget(
        //                 data.storeName,
        //                 textAlign: TextAlign.start,
        //               ), // 가게 이름 동적으로 표시
        //           loading: () => TextWidget('가게 정보 불러오는 중...'),
        //           error: (e, _) => TextWidget('가게 정보를 불러올 수 없습니다.')),
        //       Row(
        //         children: [
        //           TextWidget('내 웨이팅 번호는 ', fontSize: 16),
        //           TextWidget(
        //             '${storeWaitingRequest.token.waiting}',
        //             fontSize: 18,
        //             color: Color(0xFFDD0000),
        //           ),
        //           TextWidget('번 이예요.', fontSize: 16),
        //         ],
        //       ),
        //       // TODO : 엄마 나 여기 몇 팀 남았는지 표시해줘.
        //       Row(
        //         children: [
        //           TextWidget('내 순서까지 ', fontSize: 16),
        //           TextWidget(
        //             '14',
        //             fontSize: 18,
        //             color: Color(0xFFDD0000),
        //           ),
        //           TextWidget('팀이 남았어요.', fontSize: 16),
        //         ],
        //       ),
        //     ],
        //   ),
        //   trailing: IconButton(
        //     icon: Icon(Icons.exit_to_app),
        //     onPressed: () => showDialog(
        //       context: context,
        //       builder: (context) => AlertDialog(
        //         title: TextWidget('웨이팅 취소'),
        //         content: TextInputWidget(
        //           controller: phoneNumberTextController,
        //           hintText: '전화번호 입력',
        //           type: TextInputType.number,
        //           ref: ref,
        //           autofillHints: [AutofillHints.telephoneNumber],
        //           isObscure: false,
        //           minLength: 11,
        //           maxLength: 11,
        //           inputFormatters: [
        //             FilteringTextInputFormatter.digitsOnly,
        //             LengthLimitingTextInputFormatter(11),
        //           ],
        //         ),
        //         actions: <Widget>[
        //           TextButton(
        //             child: TextWidget('취소'),
        //             onPressed: () => Navigator.pop(context),
        //           ),
        //           TextButton(
        //             child: TextWidget('확인'),
        //             onPressed: () {
        //               if (!_formKey.currentState!.validate()) {
        //                 return;
        //               }
        //               final enteredCode = phoneNumberTextController.text;
        //               final phoneNumber = storeWaitingRequest.token.phoneNumber;
        //               print("enteredCode: $enteredCode");
        //               print("phoneNumber: $phoneNumber");

        //               if (enteredCode == phoneNumber) {
        //                 ref
        //                     .read(storeWaitingRequestNotifierProvider.notifier)
        //                     .sendWaitingCancelRequest(
        //                         storeWaitingRequest.token.storeCode,
        //                         storeWaitingRequest.token.phoneNumber);
        //                 Navigator.pop(context);
        //               } else {
        //                 ScaffoldMessenger.of(context).showSnackBar(
        //                     SnackBar(content: TextWidget('전화번호가 일치하지 않습니다.')));
        //               }
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
      ),
    );
  }
}
