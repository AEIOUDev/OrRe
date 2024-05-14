import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/permission/permission_request_phone.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/widget/custom_scroll_view/csv_divider_widget.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';

import '../../model/store_info_model.dart';
import '../../provider/network/websocket/store_detail_info_state_notifier.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/presenter/storeinfo/store_info_screen_waiting_status.dart';
import './store_info_screen_button_selector.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeDetailInfoProvider.notifier).clearStoreDetailInfo();
      ref
          .read(storeDetailInfoProvider.notifier)
          .subscribeStoreDetailInfo(widget.storeCode);
      ref
          .read(storeDetailInfoProvider.notifier)
          .sendStoreDetailInfoRequest(widget.storeCode);
    });
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
    final cancelState = ref.watch(cancelDialogStatus);
    if (cancelState != null) {
      print("!!!!!!!!!!cancel state: $cancelState");
      Future.microtask(() {
        if (cancelState == 1103) {
          ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
              context: context,
              builder: (context) {
                return AlertPopupWidget(
                  title: '웨이팅 취소',
                  subtitle: '웨이팅이 가게에 의해 취소되었습니다.',
                  buttonText: '확인',
                );
              });
        } else if (cancelState == 200) {
          ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
              context: context,
              builder: (context) {
                return AlertPopupWidget(
                  title: '웨이팅 취소',
                  subtitle: '웨이팅을 취소했습니다.',
                  buttonText: '확인',
                );
              });
        } else if (cancelState == 1102) {
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
              context: context,
              builder: (context) {
                return AlertPopupWidget(
                  title: '웨이팅 취소 실패',
                  subtitle: '가게에 문의해주세요.',
                  buttonText: '확인',
                );
              });
        }
      }).catchError((e) {
        print("error: $e");
      });
    }

    final userCallAlert = ref.watch(userCallAlertProvider);

    if (userCallAlert) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userCallAlertProvider.notifier).state = false;
        showDialog(
            context: context,
            builder: (context) {
              return AlertPopupWidget(
                title: '입장 알림',
                subtitle:
                    "제한 시간 이내에 매장에 입장해주세요!\n입장 시간이 지나면 다음 대기자에게 넘어갈 수 있습니다.",
                buttonText: '빨리 갈게요!',
              );
            });
      });
    }

    print("asyncStoreDetailInfo: ${storeDetailInfo?.storeCode}");

    if (storeDetailInfo == null) {
      print("storeDetailInfo is null");
      print("subscribeStoreDetailInfo: ${widget.storeCode}");
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return buildScaffold(context, storeDetailInfo);
    }
  }

  Widget buildScaffold(BuildContext context, StoreDetailInfo? storeDetailInfo) {
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    print('storeDetailInfo!!!!!: ${storeDetailInfo?.storeCode}');
    if (storeDetailInfo == null || storeDetailInfo.storeCode == 0) {
      // TODO : Show error message
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: new Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0xFFFFB74D), // 배경색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25), // 아래쪽 모서리 둥글게
                    bottomRight: Radius.circular(25),
                  ),
                ),
                leading: IconButton(
                  // 왼쪽 상단 뒤로가기 아이콘
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    // 오른쪽 상단 전화 아이콘
                    icon: Icon(Icons.phone, color: Colors.white),
                    onPressed: () async {
                      // Call the store
                      final status = await Permission.phone.request();
                      print("status: $status");
                      if (status.isGranted) {
                        print('Permission granted');
                        print(
                            'Call the store: ${storeDetailInfo.storePhoneNumber}');
                        await FlutterPhoneDirectCaller.callNumber(
                            storeDetailInfo.storePhoneNumber);
                      } else {
                        print('Permission denied');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PermissionRequestPhoneScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {
                      // Navigate to the store detail info page
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => StoreDetailInfoScreen(
                      //         storeDetailInfo: storeDetailInfo),
                      //   ),
                      // );
                    },
                  ),
                ],
                expandedHeight: 240, // 높이 설정
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: TextWidget(
                    storeDetailInfo.storeName,
                    color: Colors.white,
                    fontSize: 32,
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
                floating: true, // 스크롤 올릴 때 축소될지 여부
                snap: true, // 스크롤을 빨리 움직일 때 자동으로 확장/축소될지 여부
              ),
              WaitingStatusWidget(
                  storeCode: widget.storeCode, myWaitingInfo: myWaitingInfo),
              StoreMenuCategoryListWidget(storeDetailInfo: storeDetailInfo),
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
                child: BottomButtonSelector(
                  storeCode: widget.storeCode,
                  waitingState: (myWaitingInfo != null),
                ),
                width: MediaQuery.of(context).size.width * 0.95,
              )
            : null,
      );
    }
  }
}
