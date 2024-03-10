import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/location_info_provider.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/services/geocording/geocording_library_service.dart';

import '../../services/geocording/naver_map_services.dart';

// 마커 상태를 관리하는 프로바이더를 정의합니다. 처음에는 마커가 없으므로 null로 초기화합니다.
final markerProvider = StateProvider<NMarker?>((ref) => null);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('새 위치 추가'), // 앱 바 제목 설정
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: ref.watch(locationProvider.future), // 위치 정보를 비동기적으로 가져옵니다.
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 데이터 로딩 중에는 로딩 인디케이터를 보여줍니다.
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // 데이터 로딩 중 오류가 발생하면 오류 메시지를 보여줍니다.
                return Center(child: Text('위치 정보를 가져오는 데 실패했습니다.'));
              } else {
                // 데이터 로딩이 성공하면 지도를 표시합니다.
                final userLocationInfo = snapshot.data; // 사용자 위치 정보
                final latitude =
                    userLocationInfo.locationInfo?.latitude ?? 0; // 위도
                final longitude =
                    userLocationInfo.locationInfo?.longitude ?? 0; // 경도

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
          Positioned(
            bottom: 50,
            right: 10,
            left: 10,
            child: Consumer(
              builder: (context, ref, child) {
                final marker = ref.watch(markerProvider); // 현재 마커 상태를 가져옵니다.
                return ElevatedButton(
                  onPressed: marker != null
                      ? () async {
                          // 비동기 함수로 변경
                          final latitude = marker.position.latitude;
                          final longitude = marker.position.longitude;
                          final length = ref
                              .watch(locationListProvider.notifier)
                              .state
                              .locations
                              .length;

                          // getAddressFromLatLng를 비동기적으로 호출
                          // Naver API는 잠시 비활성화
                          // String? name = await getAddressFromLatLngNaver(
                          //     latitude, longitude, 3, false);
                          // String? address = await getAddressFromLatLngNaver(
                          //     latitude, longitude, 4, true);

                          // Geocording API 임시로 사용 (비용 문제)
                          String? nameLibrary =
                              await getAddressFromLatLngLibrary(
                                  latitude, longitude, 3, false);
                          String? addressLibrary =
                              await getAddressFromLatLngLibrary(
                                  latitude, longitude, 4, true);
                          print("Marker name: $nameLibrary");
                          print("Marker Address: $addressLibrary");

                          if (addressLibrary != null) {
                            // 성공적으로 주소를 가져왔을 경우의 로직
                            ref
                                .read(locationListProvider.notifier)
                                .addLocation(LocationInfo(
                                  locationName: nameLibrary ??
                                      "즐겨찾기" +
                                          length.toString(), // 주소를 위치 이름으로 사용
                                  latitude: latitude,
                                  longitude: longitude,
                                  address: addressLibrary, // 실제 주소 데이터
                                ));
                            Navigator.pop(context, marker.position); // 화면 닫기
                          } else {
                            // 주소를 가져오는데 실패했을 경우의 처리
                            print("Failed to fetch address");
                          }
                        }
                      : null, // 마커가 null이면 버튼을 비활성화합니다.
                  child:
                      Text(marker != null ? "선택된 위치 추가하기" : "원하는 위치를 클릭해보세요"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
