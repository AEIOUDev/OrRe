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

  @override
  Widget build(BuildContext context) {
    final storeDetailInfo = ref.watch(storeDetailInfoProvider);
    _handleCancelState();
    _handleUserCallAlert();

    if (storeDetailInfo == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return buildScaffold(context, storeDetailInfo);
    }
  }

  void _handleCancelState() {
    final cancelState = ref.watch(cancelDialogStatus);
    if (cancelState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (cancelState == 1103 || cancelState == 200) {
          ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();
          ref
              .read(storeWaitingRequestNotifierProvider.notifier)
              .unSubscribe(widget.storeCode);
          ref.read(cancelDialogStatus.notifier).state = null;
          showDialog(
            context: context,
            builder: (context) {
              return AlertPopupWidget(
                title: '웨이팅 취소',
                subtitle: cancelState == 1103
                    ? '웨이팅이 가게에 의해 취소되었습니다.'
                    : '웨이팅을 취소했습니다.',
                buttonText: '확인',
              );
            },
          );
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
            },
          );
        }
      });
    }
  }

  void _handleUserCallAlert() {
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
          },
        );
      });
    }
  }

  Widget buildScaffold(BuildContext context, StoreDetailInfo? storeDetailInfo) {
    final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider);
    if (storeDetailInfo == null || storeDetailInfo.storeCode == 0) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: Container(
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
                          final status = await Permission.phone.request();
                          if (status.isGranted) {
                            await FlutterPhoneDirectCaller.callNumber(
                                storeDetailInfo.storePhoneNumber);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PermissionRequestPhoneScreen(),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.phone),
                      ),
                    );
                  },
                  (context, expandRatio, barHeight, overlapsContent) {
                    return SizedBox(
                      height: barHeight,
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.info),
                        onPressed: () {
                          // 상세 정보 페이지로 이동하는 코드
                        },
                      ),
                    );
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
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: contentHeight,
                        padding: centerPadding.copyWith(
                          left: 10 + (1 - expandRatio) * 40,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: TextWidget(
                            storeDetailInfo.storeName,
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
                    ],
                  );
                },
              ),
              CSVDividerWidget(),
              WaitingStatusWidget(
                storeCode: widget.storeCode,
                myWaitingInfo: myWaitingInfo,
              ),
              CSVDividerWidget(),
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

  Shader _shaderCallback(Rect rect) {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.black, Colors.transparent],
      stops: [0.6, 1],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  }
}
