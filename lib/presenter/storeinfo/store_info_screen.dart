import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_waiting_request_model.dart';
import 'package:orre/presenter/storeinfo/store_detail_info_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/custom_scroll_view/csv_divider_widget.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text_field/text_input_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';

import '../../model/store_info_model.dart';
import '../../provider/store_detail_info_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import '../../provider/waiting_usercall_time_list_state_notifier.dart';

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
    ref.read(storeDetailInfoProvider.notifier).fetchStoreDetailInfo(
          StoreInfoParams(widget.storeCode, 0),
        );
  }

  Shader _shaderCallback(Rect rect) {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.black, Colors.transparent],
      stops: [0.6, 1],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  }

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeDetailInfoProvider);
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);

    return Scaffold(
      body: storeDetailInfo.storeCode == 0
          ? Center(child: CircularProgressIndicator()) // TODO: 추후 에러 페이지로 변경
          : new Container(
              color: Colors.white,
              child: CustomScrollView(
                slivers: [
                  SliverAppBarBuilder(
                    backgroundColorAll: Colors.orange,
                    backgroundColorBar: Colors.transparent,
                    debug: false,
                    barHeight: 40,
                    initialBarHeight: 40,
                    pinned: true,
                    leadingActions: [
                      (context, expandRatio, barHeight, overlapsContent) {
                        return SizedBox(
                          height: barHeight,
                          child: const BackButton(color: Colors.white),
                        );
                      }
                    ],
                    trailingActions: [
                      (context, expandRatio, barHeight, overlapsContent) {
                        return SizedBox(
                            height: barHeight,
                            child: IconButton(
                              color: Colors.white,
                              onPressed: () async {
                                // Call the store
                                print(
                                    'Call the store: ${storeDetailInfo.storePhoneNumber}');
                                await FlutterPhoneDirectCaller.callNumber(
                                    storeDetailInfo.storePhoneNumber);
                              },
                              icon: Icon(Icons.phone),
                            ));
                      },
                      (context, expandRatio, barHeight, overlapsContent) {
                        return SizedBox(
                            height: barHeight,
                            child: IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.info),
                              onPressed: () {
                                // Navigate to the store detail info page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StoreDetailInfoScreen(
                                        storeDetailInfo: storeDetailInfo),
                                  ),
                                );
                              },
                            ));
                      }
                    ],
                    initialContentHeight: 400,
                    contentBuilder: (
                      context,
                      expandRatio,
                      contentHeight,
                      centerPadding,
                      overlapsContent,
                    ) {
                      return Stack(
                        children: [
                          // All height image that fades away on scroll.
                          Opacity(
                            opacity: expandRatio,
                            child: ShaderMask(
                              shaderCallback: _shaderCallback,
                              blendMode: BlendMode.dstIn,
                              child: Image(
                                  height: contentHeight,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                  alignment: Alignment.topCenter,
                                  image: CachedNetworkImageProvider(
                                    storeDetailInfo.storeImageMain,
                                  )),
                            ),
                          ),

                          // Using alignment and padding, centers text to center of bar.
                          Container(
                            alignment: Alignment.centerLeft,
                            height: contentHeight,
                            padding: centerPadding.copyWith(
                              left: 10 + (1 - expandRatio) * 40,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                storeDetailInfo.storeName,
                                style: TextStyle(
                                  fontSize: 24 + expandRatio * 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Color.lerp(
                                            Colors.black,
                                            Colors.transparent,
                                            1 - expandRatio,
                                          ) ??
                                          Colors.transparent,
                                      blurRadius: 10,
                                      offset: const Offset(4, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  CSVDividerWidget(),
                  WaitingStatusWidget(
                      storeCode: widget.storeCode,
                      myWaitingInfo: myWaitingInfo),
                  CSVDividerWidget(),
                  StoreMenuListWidget(storeDetailInfo: storeDetailInfo),
                  PopScope(
                    child: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 80,
                      ),
                    ),
                    onPopInvoked: (didPop) {
                      if (didPop) {
                        ref
                            .read(storeDetailInfoProvider.notifier)
                            .clearStoreDetailInfo();
                      }
                    },
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: storeDetailInfo != StoreDetailInfo.nullValue()
          ? SizedBox(
              child: BottomButtonSelecter(
                storeCode: widget.storeCode,
                waitingState: (myWaitingInfo != null),
              ),
              width: MediaQuery.of(context).size.width * 0.95,
            )
          : null,
    );
  }
}

class WaitingStatusWidget extends ConsumerWidget {
  final int storeCode;
  final StoreWaitingRequest? myWaitingInfo;

  WaitingStatusWidget({required this.storeCode, this.myWaitingInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("WaitingStatusWidget");
    print("storeCode: $storeCode");
    final storeWaitingInfo = ref
        .watch(storeWaitingInfoNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .first;
    storeWaitingInfo.waitingTeamList.forEach((element) {
      print("waitingTeamList: $element");
    });
    final myUserCall = ref
        .watch(storeWaitingUserCallNotifierProvider.select((value) =>
            value.where((element) => element.storeCode == storeCode)))
        .firstOrNull;
    final remaingTime = ref.watch(waitingUserCallTimeListProvider);

    if (myWaitingInfo != null) {
      final myWaitingNumber = myWaitingInfo!.token.waiting;
      print("myWaitingNumber" + {myWaitingNumber}.toString());
      final int myWaitingIndex = storeWaitingInfo.waitingTeamList
          .indexWhere((team) => team == myWaitingNumber);
      print("myWaitingIndex" + {myWaitingIndex}.toString());
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(storeCode, myWaitingNumber);
      if (myUserCall != null) {
        final enteringTime = myUserCall.entryTime;
        print("enteringTime" + {enteringTime}.toString());
        print("nowTime" + {DateTime.now()}.toString());

        return SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('내 웨이팅 번호: ${myWaitingInfo?.token.waiting}'),
              Text('남은 팀 수 :  ${myWaitingIndex.toString()}'),
              Text('남은 입장 시간: ${remaingTime.inSeconds}초'),
            ],
          ),
        );
      } else {
        // if (myWaitingIndex == -1) {
        //   return SliverToBoxAdapter(
        //     child: Container(
        //       height: 50,
        //       width: 50,
        //       alignment: Alignment.center,
        //       child: CircularProgressIndicator(
        //         color: Colors.orange,
        //       ),
        //     ),
        //   );
        // } else {
        return SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('내 웨이팅 번호: ${myWaitingInfo?.token.waiting}'),
              Text('남은 팀 수 :  ${myWaitingIndex.toString()}'),
              Text(
                  '예상 대기 시간: ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
            ],
          ),
        );
      }
    } else {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            Text('대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}'),
            Text(
                '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
            Divider(),
          ],
        ),
      );
    }
  }
}

class StoreMenuListWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreMenuListWidget({required this.storeDetailInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storeDetailInfo.menuInfo.length < 1) {
      return SliverToBoxAdapter(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 50),
              Text('메뉴 정보가 없습니다.'),
            ],
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: storeDetailInfo.menuInfo.length,
          itemBuilder: (context, index) {
            final menu = storeDetailInfo.menuInfo[index];
            return Material(
              child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: menu.image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  title: Text(menu.menu),
                  subtitle: Text('${menu.price}원 - ${menu.introduce}'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Scaffold(
                          appBar: AppBar(
                            title: Text(menu.menu),
                          ),
                          body: PhotoView(
                            imageProvider:
                                CachedNetworkImageProvider(menu.image),
                          ));
                    }));
                  }),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      );
    }
  }
}

class BottomButtonSelecter extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  BottomButtonSelecter({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowWaitable =
        ref.watch(storeDetailInfoProvider.notifier).isCanReserve();

    if (nowWaitable) {
      return WaitingButton(storeCode: storeCode, waitingState: waitingState);
    } else {
      return FloatingActionButton.extended(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("예약 불가"),
                  content: Text("현재 예약이 불가능한 시간입니다."),
                  actions: [
                    TextButton(
                      child: Text("확인"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          label: Text('예약 불가'));
    }
  }
}

class WaitingButton extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingButton({required this.storeCode, required this.waitingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          print("waitingState" + {waitingState}.toString());
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return waitingState
                  ? WaitingCancleDialog(
                      storeCode: storeCode, waitingState: waitingState)
                  : WaitingDialog(
                      storeCode: storeCode,
                      waitingState: waitingState,
                    );
            },
          );
        },
        label: waitingState
            ? Row(
                children: [
                  Icon(Icons.person_remove_alt_1),
                  SizedBox(width: 8),
                  Text('웨이팅 취소'),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text('웨이팅 시작'),
                ],
              ));
  }
}

final peopleNumberProvider = StateProvider<int>((ref) => 1);

class WaitingDialog extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingDialog({required this.storeCode, required this.waitingState});

  // 웨이팅 시작을 위한 정보 입력 다이얼로그 표시
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumberController = TextEditingController();
    final userInfo = ref.watch(userInfoProvider);
    final numberOfPersonControlloer = ref.watch(peopleNumberProvider);

    phoneNumberController.text = userInfo?.phoneNumber ?? "";

    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text("웨이팅 시작"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextInputWidget(
              hintText: "전화번호",
              controller: phoneNumberController,
              isObscure: false,
              type: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              minLength: 11,
              maxLength: 11,
              ref: ref,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (numberOfPersonControlloer > 1) {
                      ref.read(peopleNumberProvider.notifier).state--;
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: AnimatedFlipCounter(
                    value: numberOfPersonControlloer,
                    suffix: "명",
                    textStyle: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    ref.read(peopleNumberProvider.notifier).state++;
                  },
                ),
              ],
            ),
          ],
        ),
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
            if (formKey.currentState!.validate()) {
              // 여기에서 입력된 정보를 처리합니다.
              // 예를 들어, 웨이팅 요청을 서버에 보내는 로직을 구현할 수 있습니다.
              print("전화번호: ${phoneNumberController.text}");
              print("인원 수: ${numberOfPersonControlloer}");
              print("가게 코드: $storeCode");
              print("웨이팅 시작");
              subscribeAndShowDialog(
                  context,
                  storeCode,
                  phoneNumberController.text,
                  numberOfPersonControlloer.toString(),
                  ref);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void subscribeAndShowDialog(BuildContext context, int storeCode,
      String phoneNumber, String numberOfPersons, WidgetRef ref) {
    // 스트림 구독
    print("subscribeAndShowDialog");
    final stream =
        ref.watch(storeWaitingRequestNotifierProvider.notifier).startSubscribe(
              storeCode,
              phoneNumber,
              int.parse(numberOfPersons),
            );
    ref.read(storeWaitingRequestNotifierProvider.notifier).sendWaitingRequest(
          storeCode,
          phoneNumber,
          int.parse(numberOfPersons),
        );

    print("stream: $stream");
    // 스트림의 각 결과에 대해 다른 대화 상자를 표시
    stream.then((result) {
      print("result: $result");
      if (result) {
        final myWaitingInfo = ref.read(storeWaitingRequestNotifierProvider);
        // 결과가 true 일 때의 대화 상자
        showDialog(
          context: context,
          builder: (context) => AlertPopupWidget(
            title: '웨이팅 성공',
            subtitle: '대기번호 ${myWaitingInfo?.token.waiting}번으로 웨이팅 되었습니다.',
            buttonText: 'OK',
          ),
        );
      } else {
        // 결과가 false 일 때의 대화 상자
        showDialog(
          context: context,
          builder: (context) => AlertPopupWidget(
            title: '웨이팅 실패',
            subtitle: '잠시 후에 다시 시도해 주세요.',
            buttonText: '확인',
          ),
        );
      }
    }, onError: (error) {
      // 스트림에서 에러 발생 시 처리
      showDialog(
        context: context,
        builder: (context) => AlertPopupWidget(
          title: '웨이팅 에러',
          subtitle: '잠시 후에 다시 시도해 주세요.',
          buttonText: '확인',
        ),
      );
    });
  }
}

class WaitingCancleDialog extends ConsumerWidget {
  final int storeCode;
  final bool waitingState;

  WaitingCancleDialog({required this.storeCode, required this.waitingState});

  // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
    final waitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    final phoneNumberController = TextEditingController();
    phoneNumberController.text = waitingInfo?.token.phoneNumber ?? "";
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text("웨이팅 취소"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextInputWidget(
              hintText: "전화번호",
              controller: phoneNumberController,
              isObscure: false,
              type: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              minLength: 11,
              maxLength: 11,
              ref: ref,
            ),
          ],
        ),
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
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              // 여기에서 입력된 정보를 처리합니다.
              // 예를 들어, 웨이팅 취소 요청을 서버에 보내는 로직을 구현할 수 있습니다.
              print("전화번호: ${phoneNumberController.text}");
              print("가게 코드: $storeCode");
              print("웨이팅 취소");
              ref
                  .read(storeWaitingRequestNotifierProvider.notifier)
                  .sendWaitingCancleRequest(
                      storeCode, phoneNumberController.text);

              if (waitingInfo != null) {
                print("waitingInfo != null" + {waitingInfo.status}.toString());
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertPopupWidget(
                        title: '웨이팅 취소',
                        subtitle: '웨이팅이 취소되었습니다.',
                        buttonText: '확인',
                      );
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertPopupWidget(
                        title: '웨이팅 취소',
                        subtitle: '웨이팅이 취소되지 않았습니다.',
                        buttonText: '확인',
                      );
                    });
              }
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
