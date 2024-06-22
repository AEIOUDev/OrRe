import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/services/debug_services.dart';
import 'package:orre/services/hardware/haptic_services.dart';
import 'package:orre/widget/custom_scroll_view/csv_sizedbox_widget.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import '../../model/store_info_model.dart';
import '../../provider/network/websocket/store_detail_info_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../widget/popup/awesome_dialog_widget.dart';
import './store_info_screen_button_selector.dart';
import 'store_info_location_widget.dart';
import 'store_info_screen_waiting_status.dart';

class StoreDetailInfoWidget extends ConsumerStatefulWidget {
  final int storeCode;

  StoreDetailInfoWidget({Key? key, required this.storeCode}) : super(key: key);

  @override
  _StoreDetailInfoWidgetState createState() => _StoreDetailInfoWidgetState();
}

class _StoreDetailInfoWidgetState extends ConsumerState<StoreDetailInfoWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    printd("\n\nStoreDetailInfoWidget didChangeDependencies 진입");
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currentDetailInfo = ref.read(storeDetailInfoWebsocketProvider);
      if (currentDetailInfo == null ||
          currentDetailInfo.storeCode != widget.storeCode) {
        ref
            .read(storeDetailInfoWebsocketProvider.notifier)
            .clearStoreDetailInfo();
        ref
            .read(storeDetailInfoWebsocketProvider.notifier)
            .subscribeStoreDetailInfo(widget.storeCode);
        ref
            .read(storeDetailInfoWebsocketProvider.notifier)
            .sendStoreDetailInfoRequest(widget.storeCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    printd("\n\nStoreDetailInfoWidget build 진입");
    final storeDetailInfo = ref.watch(storeDetailInfoWebsocketProvider);
    _handleCancelState();
    // _handleUserCallAlert();

    if (storeDetailInfo == null) {
      return Scaffold(
        body: CustomLoadingIndicator(
          message: "가게 정보 불러오는 중..",
        ),
      );
    } else {
      return buildScaffold(context, storeDetailInfo);
    }
  }

  void _handleCancelState() {
    final cancelState = ref.watch(cancelDialogStatus);
    if (cancelState != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (navigatorKey.currentContext == null) return;
          if (cancelState == 1103 || cancelState == 200) {
            ref
                .read(storeWaitingUserCallNotifierProvider.notifier)
                .unSubscribe();
            ref
                .read(storeWaitingRequestNotifierProvider.notifier)
                .unSubscribe(widget.storeCode);
            ref.read(cancelDialogStatus.notifier).state = null;
            // showDialog(
            //   context: navigatorKey.currentContext!,
            //   builder: (context) {
            //     return AlertPopupWidget(
            //       title: '웨이팅 취소',
            //       subtitle: cancelState == 1103
            //           ? '웨이팅이 가게에 의해 취소되었습니다.'
            //           : '웨이팅을 취소했습니다.',
            //       buttonText: '확인',
            //     );
            //   },
            // );
          } else if (cancelState == 1102) {
            ref.read(cancelDialogStatus.notifier).state = null;
            AwesomeDialogWidget.showErrorDialog(
              context: navigatorKey.currentContext!,
              title: '웨이팅 취소 실패',
              desc: '가게에 문의해주세요.',
            );
          }
        },
      );
    }
  }

  // void _handleUserCallAlert() {
  //   final userCallAlert = ref.watch(userCallAlertProvider);
  //   if (userCallAlert) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ref.read(userCallAlertProvider.notifier).state = false;
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertPopupWidget(
  //             title: '입장 알림',
  //             subtitle:
  //                 "제한 시간 이내에 매장에 입장해주세요!\n입장 시간이 지나면 다음 대기자에게 넘어갈 수 있습니다.",
  //             buttonText: '빨리 갈게요!',
  //           );
  //         },
  //       );
  //     });
  //   }
  // }

  Widget buildScaffold(BuildContext context, StoreDetailInfo? storeDetailInfo) {
    printd("\n\nStoreDetailInfoWidget buildScaffold 진입");
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    if (storeDetailInfo == null || storeDetailInfo.storeCode == 0) {
      return Scaffold(
        body: CustomLoadingIndicator(
          message: "가게 정보 불러오는 중..",
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0xFFFFB74D), // 배경색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30), // 아래쪽 모서리 둥글게
                    bottomRight: Radius.circular(30),
                  ),
                ),
                leading: IconButton(
                  // 왼쪽 상단 뒤로가기 아이콘
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () async {
                    await HapticServices.vibrate(
                        ref, CustomHapticsType.selection);
                    context.pop();
                  },
                ),
                actions: [
                  IconButton(
                    // 오른쪽 상단 전화 아이콘
                    icon: Icon(Icons.phone, color: Colors.white),
                    onPressed: () async {
                      await HapticServices.vibrate(
                          ref, CustomHapticsType.selection);
                      // Call the store
                      final status = await Permission.phone.request();
                      printd("status: $status");
                      if (status.isGranted || Platform.isIOS) {
                        printd('Permission granted');
                        printd(
                            'Call the store: ${storeDetailInfo.storePhoneNumber}');
                        await FlutterPhoneDirectCaller.callNumber(
                            storeDetailInfo.storePhoneNumber);
                      } else {
                        printd('Permission denied');
                        AwesomeDialogWidget.showCustomDialogWithCancel(
                          context: context,
                          title: "전화 권한",
                          desc: "전화 권한이 없습니다. 설정으로 이동하여 권한을 허용해주세요.",
                          dialogType: DialogType.warning,
                          onPressed: () async {
                            await HapticServices.vibrate(
                                ref, CustomHapticsType.selection);
                            openAppSettings();
                          },
                          btnText: "설정으로 이동",
                          onCancel: () {},
                          cancelText: "취소",
                        );
                      }
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.info_outline, color: Colors.white),
                  //   onPressed: () {
                  //     // Navigate to the store detail info page
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => StoreDetailInfoScreen(
                  //     //         storeDetailInfo: storeDetailInfo),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  SizedBox(width: 8.w)
                ],
                expandedHeight: 240, // 높이 설정
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(bottom: 14.h),
                  title: TextWidget(
                    storeDetailInfo.storeName,
                    color: Colors.white,
                    fontSize: 24.sp,
                    textAlign: TextAlign.center,
                  ),
                  background: Container(
                    width: 130,
                    height: 130,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFB74D), // 원모양 배경색
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image(
                        image: CachedNetworkImageProvider(
                            storeDetailInfo.storeImageMain),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      ),
                    ),
                  ),
                ),
                pinned: true, // 스크롤시 고정
                toolbarHeight: 58.h,
              ),
              WaitingStatusWidget(
                storeCode: widget.storeCode,
                myWaitingInfo: myWaitingInfo,
                locationInfo: storeDetailInfo.locationInfo,
              ),
              CSVSizedBoxWidget(height: 32.h),
              StoreLocationWidget(storeDetailInfo: storeDetailInfo),
              CSVSizedBoxWidget(height: 32.h),
              StoreMenuCategoryListWidget(storeDetailInfo: storeDetailInfo),
              CSVSizedBoxWidget(height: 32.h),
              PopScope(
                child: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                  ),
                ),
                onPopInvoked: (didPop) {
                  if (didPop) {
                    ref
                        .read(storeDetailInfoWebsocketProvider.notifier)
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
                child: BottomButtonSelector(
                  storeCode: widget.storeCode,
                  waitingState: (myWaitingInfo != null),
                  nowWaitable: storeDetailInfo.waitingAvailable == 0,
                ),
                width: 0.95.sw,
              )
            : null,
      );
    }
  }
}
