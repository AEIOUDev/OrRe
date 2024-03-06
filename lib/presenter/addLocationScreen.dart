import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/location_info_provider.dart';

// 마커 상태를 관리하는 프로바이더
final markerProvider = StateProvider<NMarker?>((ref) => null);

class AddLocationScreen extends ConsumerStatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  late NaverMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 위치 추가'),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: ref.watch(locationProvider.future),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('위치 정보를 가져오는 데 실패했습니다.'));
              } else {
                // 성공적으로 위치 정보를 가져온 경우
                final userLocation = snapshot.data;
                final latitude = userLocation.locationInfo?.latitude ?? 0;
                final longitude = userLocation.locationInfo?.longitude ?? 0;

                return NaverMap(
                  options: NaverMapViewOptions(
                    locale: Locale('ko-kr'),
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(latitude, longitude),
                      zoom: 15,
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
                  ),
                  onMapReady: (controller) {
                    _mapController = controller;
                  },
                  onMapTapped: (point, latLng) {
                    // 새 마커 객체를 생성합니다.
                    final newMarker = NMarker(
                      id: "selectedMarker",
                      position: latLng,
                    );

                    // 마커 상태를 업데이트합니다.
                    ref.read(markerProvider.notifier).state = newMarker;

                    // 새로운 마커를 지도에 추가합니다.
                    _mapController.addOverlay(newMarker);
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
                // Consumer 위젯 내에서 ref를 사용하여 프로바이더의 상태를 구독합니다.
                final marker = ref.watch(markerProvider);
                final markerInfo = ref.watch(markerProvider.notifier).state;
                return ElevatedButton(
                  onPressed: marker != null
                      ? () {
                          // 마커가 선택되었을 때의 로직
                          print(markerInfo?.info.id);
                          print(markerInfo?.position);
                        }
                      : null,
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
