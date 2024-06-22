import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug_services.dart';

// 마커 상태를 관리하는 프로바이더를 정의합니다. 처음에는 마커가 없으므로 null로 초기화합니다.
final markerProvider = StateProvider<NMarker?>((ref) => null);

// ConsumerStatefulWidget을 상속받는 AddLocationScreen 클래스를 정의합니다.
class StoreLocationWidget extends ConsumerStatefulWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreLocationWidget({super.key, required this.storeDetailInfo}); // 가게 정보
  @override
  // 상태 관리 클래스를 생성합니다.
  _StoreLocationWidgetState createState() => _StoreLocationWidgetState();
}

// 상태 관리 클래스에서는 Flutter의 StatefulWidget의 상태 관리 기능을 활용합니다.
class _StoreLocationWidgetState extends ConsumerState<StoreLocationWidget> {
  late NaverMapController _mapController; // NaverMapController를 late로 선언합니다.

  @override
  Widget build(BuildContext context) {
    printd("\n\StoreLocationWidget 진입");
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 16.w),
              TextWidget("위치 정보",
                  fontSize: 24.sp,
                  color: Color(0xFFFFB74D),
                  textAlign: TextAlign.center),
              Spacer(),
              TextWidget("지도를 터치하면 가게 위치로 돌아갑니다.",
                  fontSize: 10.sp,
                  color: Colors.grey,
                  textAlign: TextAlign.center),
              SizedBox(width: 16.w),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            height: 200.h,
            margin: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            child: Expanded(
              flex: 4,
              child: FutureBuilder(
                future: ref
                    .read(nowLocationProvider.notifier)
                    .updateNowLocation(), // 위치 정보를 비동기적으로 가져옵니다.
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 데이터 로딩 중에는 로딩 인디케이터를 보여줍니다.
                    printd(
                        "snapshot.connectionState: ${snapshot.connectionState}");
                    return CustomLoadingIndicator(message: "위치 정보를 가져오는 중..");
                  } else if (snapshot.hasError) {
                    // 데이터 로딩 중 오류가 발생하면 오류 메시지를 보여줍니다.
                    printd("snapshot.error: ${snapshot.error}");
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref
                          .read(errorStateNotifierProvider.notifier)
                          .addError(Error.locationPermission);
                    });
                    return Center(child: TextWidget('위치 정보를 가져오는 데 실패했습니다.'));
                  } else {
                    printd("snapshot.data: ${snapshot.data}");
                    // 데이터 로딩이 성공하면 지도를 표시합니다.
                    final latitude =
                        widget.storeDetailInfo.locationInfo.latitude;
                    final longitude =
                        widget.storeDetailInfo.locationInfo.longitude;
                    final target = NLatLng(latitude, longitude);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(
                          30), // 이 값은 Container의 borderRadius와 일치해야 합니다.
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          locale: Locale('ko-kr'),
                          initialCameraPosition: NCameraPosition(
                            target: NLatLng(latitude, longitude),
                            zoom: 16,
                          ),
                          minZoom: 6,
                          maxZoom: 18,
                          maxTilt: 45,
                          extent: NLatLngBounds(
                            southWest: NLatLng(31.43, 122.37),
                            northEast: NLatLng(44.35, 132.0),
                          ),
                          locationButtonEnable: true,
                          indoorEnable: true,
                          logoClickEnable: false,
                          zoomGesturesEnable: false,
                        ),
                        onMapReady: (controller) {
                          _mapController = controller;
                          final marker = NMarker(
                            position: NLatLng(latitude, longitude),
                            id: 'marker',
                            // caption: NOverlayCaption(
                            //   text: widget.storeDetailInfo.storeName,
                            //   textSize: 12.sp,
                            // ),
                            // captionAligns: [NAlign.top],
                          );
                          _mapController.addOverlay(marker);
                        },
                        onMapTapped: (point, latLng) {
                          // 초기 위치로 이동합니다.
                          _mapController.updateCamera(
                            // NCameraUpdate.scrollBy(0, 0),
                            NCameraUpdate.scrollAndZoomTo(
                                target: target, zoom: 16),
                          );
                        },
                        onSymbolTapped: (point) {
                          // 초기 위치로 이동합니다.
                          _mapController.updateCamera(
                            // NCameraUpdate.scrollBy(0, 0),
                            NCameraUpdate.scrollAndZoomTo(
                                target: target, zoom: 16),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget("${widget.storeDetailInfo.locationInfo.address}",
                  fontSize: 16.sp,
                  color: Colors.black,
                  textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}
