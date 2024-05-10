import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/permission/permission_request_phone.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_category_list_widget.dart';
import 'package:orre/widget/custom_scroll_view/csv_divider_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';

import '../../model/store_info_model.dart';
import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import '../../provider/store_detail_info_state_notifier.dart';
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
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => StoreDetailInfoScreen(
                                //         storeDetailInfo: storeDetailInfo),
                                //   ),
                                // );
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
                      myWaitingInfo: myWaitingInfo),
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
