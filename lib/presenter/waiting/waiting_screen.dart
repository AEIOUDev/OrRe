import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre/provider/network/https/post_store_info_future_provider.dart';
// import 'package:orre/provider/network/websocket/store_detail_info_state_notifier.dart';
import 'package:orre/provider/network/https/store_detail_info_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
// import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../services/debug.services.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  @override
  void didChangeDependencies() async {
    printd("\n\nWaitingScreen didUpdateDependencies 진입");
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo == null) {
      printd("사용자 정보 없음. 로그인 페이지로 이동");
      context.go('/user/onboarding');
    } else {
      final serviceLog = await ref
          .watch(serviceLogProvider.notifier)
          .fetchStoreServiceLog(ref.read(userInfoProvider)!.phoneNumber);
      if (serviceLog.userLogs.isNotEmpty) {
        ref
            .watch(serviceLogProvider.notifier)
            .reconnectWebsocketProvider(serviceLog.userLogs.last);
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    printd("\n\nWaitingScreen 진입");

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
          width: 1.sw,
          height: 0.9.sh,
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
                endIndent: MediaQuery.sizeOf(context).width * 0.25,
                indent: MediaQuery.sizeOf(context).width * 0.25,
              ),
              SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, irndex) {
                    final item = listOfWaitingStoreProvider;
                    if (item == null) {
                      printd("item == null");
                      return LastStoreItem();
                    } else {
                      printd("item != null");
                      return WaitingStoreItem(item);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingStoreItem extends ConsumerWidget {
  final StoreWaitingRequest storeWaitingRequest;

  WaitingStoreItem(this.storeWaitingRequest);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return FutureBuilder(
        future: fetchStoreDetailInfo(
            StoreInfoParams(storeWaitingRequest.token.storeCode, 0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoadingIndicator();
            // return Container();
          } else if (snapshot.hasError) {
            return TextWidget('Error: ${snapshot.error}');
          } else {
            final storeDetailInfo = snapshot.data;
            if (storeDetailInfo == null) {
              return TextWidget('가게 정보를 불러오지 못했습니다.');
            }
            return GestureDetector(
              onTap: () =>
                  context.push("/storeinfo/${storeDetailInfo.storeCode}"),
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
                          CachedNetworkImage(
                            imageUrl: storeDetailInfo.storeImageMain,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                storeDetailInfo.storeName,
                                textAlign: TextAlign.start,
                                fontSize: 28,
                              ), // 가게 이름 동
                              SizedBox(height: 5),
                              Consumer(
                                builder: (context, ref, child) {
                                  final serviceLog =
                                      ref.watch(serviceLogProvider);
                                  return TextWidget(
                                      serviceLog.userLogs.last.status.toKr(),
                                      fontSize: 24,
                                      color: Color(0xFFDD0000));
                                },
                              ),
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
                              StreamBuilder(
                                stream: ref
                                    .watch(storeWaitingInfoNotifierProvider
                                        .notifier)
                                    .stream,
                                builder: ((context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // return CustomLoadingIndicator();
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return TextWidget(
                                        '네트워크 에러가 발생했어요. 앱을 재시작해주세요.');
                                  } else {
                                    if (snapshot.data == null) {
                                      return TextWidget('웨이팅 정보를 불러오지 못했어요.');
                                    }
                                    return Consumer(
                                        builder: (context, ref, child) {
                                      final storeWaitingInfo = snapshot.data;
                                      final myWaitingIndex = storeWaitingInfo
                                          ?.where((element) =>
                                              element.storeCode ==
                                              storeWaitingRequest
                                                  .token.storeCode)
                                          .first
                                          .waitingTeamList
                                          .indexOf(storeWaitingRequest
                                              .token.waiting);
                                      final userCallState = ref.watch(
                                          waitingUserCallTimeListProvider);

                                      if (userCallState != null &&
                                          userCallState !=
                                              Duration(seconds: -1)) {
                                        if (userCallState.inSeconds == 0) {
                                          return TextWidget('입장마감 시간이 지났어요.');
                                        } else {
                                          return Row(
                                            children: [
                                              TextWidget(
                                                '입장 마감까지  ',
                                                fontSize: 20,
                                                textAlign: TextAlign.start,
                                              ),
                                              TextWidget(
                                                '${userCallState.inSeconds}',
                                                fontSize: 24,
                                                color: Color(0xFFDD0000),
                                              ),
                                              TextWidget('초 남았어요.',
                                                  fontSize: 20),
                                            ],
                                          );
                                        }
                                      } else if (myWaitingIndex == -1 ||
                                          myWaitingIndex == null) {
                                        return TextWidget('대기 중인 팀이 없습니다.');
                                      } else {
                                        return Row(
                                          children: [
                                            TextWidget(
                                              '내 순서까지  ',
                                              fontSize: 20,
                                              textAlign: TextAlign.start,
                                            ),
                                            TextWidget(
                                              '${myWaitingIndex}',
                                              fontSize: 24,
                                              color: Color(0xFFDD0000),
                                            ),
                                            TextWidget('팀 남았어요.', fontSize: 20),
                                          ],
                                        );
                                      }
                                    });
                                  }
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      BigButtonWidget(
                          text: '웨이팅 취소하기',
                          textColor: Colors.white,
                          backgroundColor: Color(0xFFFFBF52),
                          minimumSize: Size(double.infinity, 40),
                          onPressed: () {
                            AwesomeDialogWidget.showCustomDialogWithCancel(
                              context: context,
                              title: "웨이팅 취소",
                              desc: "정말로 웨이팅을 취소하시겠습니까?",
                              dialogType: DialogType.question,
                              onPressed: () {
                                ref
                                    .read(storeWaitingRequestNotifierProvider
                                        .notifier)
                                    .sendWaitingCancelRequest(
                                        storeWaitingRequest.token.storeCode,
                                        storeWaitingRequest.token.phoneNumber);
                              },
                              btnText: "네",
                              onCancel: () {},
                              cancelText: "아니요",
                            );
                          }),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

class LastStoreItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo == null) {
      printd("사용자 정보 없음. 로그인 페이지로 이동");
      context.go('/user/onboarding');
    } else {
      return FutureBuilder(
          future: ref
              .watch(serviceLogProvider.notifier)
              .fetchStoreServiceLog(userInfo.phoneNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError || snapshot.data == null) {
              return TextWidget('Error: ${snapshot.error}');
            } else if (snapshot.data!.userLogs.isEmpty) {
              return TextWidget('서비스 이용내역이 없습니다.',
                  fontSize: 16.sp, color: Colors.grey);
            } else {
              final serviceLog = snapshot.data;
              final storeCode = snapshot.data!.userLogs.last.storeCode;
              printd("serviceLog: ${serviceLog!.userLogs.length}");
              if (serviceLog.userLogs.isNotEmpty) {
                return FutureBuilder(
                    future: fetchStoreDetailInfo(StoreInfoParams(storeCode, 0)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return TextWidget('Error: ${snapshot.error}');
                      } else {
                        final storeDetailInfo = snapshot.data;
                        if (storeDetailInfo == null) {
                          return TextWidget('가게 정보를 불러오지 못했습니다.');
                        }
                        return GestureDetector(
                          onTap: () => context.push("/storeinfo/$storeCode"),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: storeDetailInfo.storeImageMain,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          storeDetailInfo.storeName,
                                          textAlign: TextAlign.start,
                                          fontSize: 28,
                                        ), // 가게 이름 동적으로 표시
                                        SizedBox(height: 5),
                                        TextWidget(
                                            serviceLog.userLogs.last.status
                                                .toKr(),
                                            fontSize: 24,
                                            color: Color(0xFFDD0000)),
                                        Row(
                                          children: [
                                            TextWidget('내 웨이팅 번호는 ',
                                                fontSize: 20),
                                            TextWidget(
                                              '${serviceLog.userLogs.last.waiting}',
                                              fontSize: 24,
                                              color: Color(0xFFDD0000),
                                            ),
                                            TextWidget('번이었어요.', fontSize: 20),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    });
              } else {
                return TextWidget('서비스 로그 없음.', fontSize: 24);
              }
            }
          });
    }
    return Container();
  }
}
