import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/services/geocording/geocording_library_service.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug.services.dart';

// import '../../services/geocording/naver_map_services.dart';

// 마커 상태를 관리하는 프로바이더를 정의합니다. 처음에는 마커가 없으므로 null로 초기화합니다.
final markerProvider = StateProvider<NMarker?>((ref) => null);
final addressProvider = StateProvider<String>((ref) => "");

// ConsumerStatefulWidget을 상속받는 AddLocationScreen 클래스를 정의합니다.
class AddLocationScreen extends ConsumerStatefulWidget {
  @override
  // 상태 관리 클래스를 생성합니다.
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

// 상태 관리 클래스에서는 Flutter의 StatefulWidget의 상태 관리 기능을 활용합니다.
class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  late NaverMapController _mapController; // NaverMapController를 late로 선언합니다.

  @override
  Widget build(BuildContext context) {
    printd("\n\nAddLocationScreen 진입");
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          '위치 설정하기', // 텍스트
          color: Color(0xFFFFB74D),
          fontSize: 32,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // 뒤로 가기 아이콘
          color: Color(0xFFFFB74D),
          onPressed: () {
            context.pop(); // 현재 화면을 종료하고 이전 화면으로 돌아갑니다.
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              TextWidget('지도를 움직여 원하는 위치로 이동하세요.',
                  textAlign: TextAlign.start, fontSize: 20),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: FutureBuilder(
              future: ref
                  .read(nowLocationProvider.notifier)
                  .updateNowLocation(), // 위치 정보를 비동기적으로 가져옵니다.
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 데이터 로딩 중에는 로딩 인디케이터를 보여줍니다.
                  print(
                      "snapshot.connectionState: ${snapshot.connectionState}");
                  return Center(child: CustomLoadingIndicator());
                } else if (snapshot.hasError) {
                  // 데이터 로딩 중 오류가 발생하면 오류 메시지를 보여줍니다.
                  print("snapshot.error: ${snapshot.error}");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(errorStateNotifierProvider.notifier)
                        .addError(Error.locationPermission);
                  });
                  return Center(child: TextWidget('위치 정보를 가져오는 데 실패했습니다.'));
                } else {
                  print("snapshot.data: ${snapshot.data}");
                  // 데이터 로딩이 성공하면 지도를 표시합니다.
                  final userLocationInfo = snapshot.data; // 사용자 위치 정보
                  final latitude = userLocationInfo.latitude ?? 0; // 위도
                  final longitude = userLocationInfo.longitude ?? 0; // 경도

                  return NaverMap(
                    options: NaverMapViewOptions(
                      // 지도 언어 설정
                      locale: Locale('ko-kr'),

                      // 지도 첫 로딩 시 카메라 포지션 설정
                      initialCameraPosition: NCameraPosition(
                        // 보여줄 좌표
                        target: NLatLng(latitude, longitude),

                        // 줌 레벨
                        zoom: 15,
                      ),

                      // 최소 줌 레벨
                      minZoom: 6,

                      // 최대 줌 레벨
                      maxZoom: 18,

                      // 최대 기울기 레벨
                      maxTilt: 45,

                      // 카메라 이동 범위 제한(대한민국)
                      extent: NLatLngBounds(
                        southWest: NLatLng(31.43, 122.37),
                        northEast: NLatLng(44.35, 132.0),
                      ),

                      // 내 위치 확인 버튼 활성화
                      locationButtonEnable: true,

                      // 건물 내부 보는 여부
                      indoorEnable: true,
                    ),
                    onMapReady: (controller) {
                      _mapController = controller; // 지도 컨트롤러 초기화
                    },
                    onMapTapped: (point, latLng) {
                      // 지도를 탭했을 때 새 마커 객체를 생성하고 마커 상태를 업데이트합니다.
                      final newMarker = NMarker(
                        id: "selectedMarker",
                        position: latLng,
                      );

                      ref.read(markerProvider.notifier).state =
                          newMarker; // 마커 상태 업데이트
                      print(newMarker.position);
                      _mapController.addOverlay(newMarker); // 새로운 마커를 지도에 추가
                    },
                    onSymbolTapped: (point) {
                      // 지도를 탭했을 때 새 마커 객체를 생성하고 마커 상태를 업데이트합니다.
                      final newMarker = NMarker(
                        id: "selectedMarker",
                        position: point.position,
                      );

                      ref.read(markerProvider.notifier).state =
                          newMarker; // 마커 상태 업데이트

                      _mapController.addOverlay(newMarker); // 새로운 마커를 지도에 추가
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Consumer(
              builder: (context, ref, child) {
                final marker = ref.watch(markerProvider); // 현재 마커 상태를 가져옵니다.
                // final address = ref.watch(addressProvider); // 현재 주소 상태를 가져옵니다.

                String tempAddr = "";

                // if (marker != null) {
                //   getAddressFromLatLngLibrary(marker.position.latitude,
                //           marker.position.longitude, 4, true)
                //       .then((value) {
                //     if (value != null) {
                //       tempAddr = value;
                //     }
                //   });
                // }
                ref.read(addressProvider.notifier).state = tempAddr;
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO : 엄마 여기 위치 추가되면 마커된 주소 가져와서 보여줘. <- 일단 보류
                      // TextWidget(address, fontSize: 20),
                      SizedBox(height: 8),
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: marker != null
                              ? () async {
                                  final latitude = marker.position.latitude;
                                  final longitude = marker.position.longitude;
                                  final length = ref
                                      .watch(locationListProvider)
                                      .customLocations
                                      .length;

                                  List<String?> nameAndAddress =
                                      await getAddressFromLatLngLibrary(
                                          latitude, longitude, 4, false);

                                  print("Marker name: ${nameAndAddress.first}");
                                  print(
                                      "Marker Address: ${nameAndAddress.last}");

                                  if (nameAndAddress.first != null) {
                                    ref
                                        .read(locationListProvider.notifier)
                                        .addLocation(LocationInfo(
                                          locationName: nameAndAddress.first ??
                                              "즐겨찾기" + length.toString(),
                                          latitude: latitude,
                                          longitude: longitude,
                                          address: nameAndAddress.last ?? "",
                                        ));
                                    context.pop(marker.position);
                                  } else {
                                    print("Failed to fetch address");
                                  }
                                }
                              : null,
                          child: TextWidget(
                              marker != null ? "선택된 위치 추가하기" : "원하는 위치를 클릭해보세요",
                              color: marker != null
                                  ? Colors.white
                                  : Color(0xFF999999)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: marker != null
                                ? Color(0xFFFFB74D)
                                : Color(0xFFDFDFDF),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // 모서리 둥글게 설정
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
