import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/now_location_provider.dart';

import '../provider/location/location_securestorage_provider.dart';
import '../provider/stomp_client_future_provider.dart';
import '../provider/store_location_list_state_notifier.dart';
import 'location/location_manager_screen.dart';
import 'store_info_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowLocationAsyncValue = ref.watch(nowLocationProvider);

    // AsyncValue를 사용하여 상태 처리
    return nowLocationAsyncValue.when(
      data: (data) {
        print("nowLocationProvider value : " + data.locationInfo!.locationName);
        // 데이터가 정상적으로 로드되었을 때 UI를 표시
        final location = ref.watch(locationListProvider
            .select((value) => value.selectedLocation)); // 선택된 위치
        final nowLocationName = location?.locationName;
        print("nowLocationAsyncValue : " + (nowLocationName ?? ""));
        return locationLoadedScreen(
            context, ref, location ?? data.locationInfo!);
      },
      error: (error, stack) {
        // 에러가 발생했을 때 다시 시도하도록 유도하는 UI를 표시
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('위치 정보를 불러오는데 실패했습니다.'),
                ElevatedButton(
                  onPressed: () => ref.refresh(nowLocationProvider),
                  child: Text('다시 시도하기'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _refreshCurrentLocation(BuildContext context, WidgetRef ref) async {
    print("_refreshCurrentLocation");
    try {
      // nowLocationProvider를 refresh하고 결과를 기다립니다.
      final userLocationInfo = await ref.refresh(nowLocationProvider.future);
      // 성공적으로 위치 정보를 받았으면, 이를 LocationListProvider에 업데이트합니다.
      ref
          .read(locationListProvider.notifier)
          .updateNowLocation(userLocationInfo.locationInfo!);
    } catch (error) {
      // 에러 처리...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 위치를 불러오는데 실패했습니다.')),
      );
    }
  }

// 데이터가 정상적으로 로드되었을 때 화면 구성
  Widget locationLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    final stompClient = ref.watch(stompClientProvider);
    print("locationLoadedScreen");

    // AsyncValue를 사용하여 상태 처리
    return stompClient.when(
      data: (data) {
        // 데이터가 정상적으로 로드되었을 때 UI를 표시
        return stompLoadedScreen(context, ref, location);
      },
      error: (error, stack) {
        print(error);
        // 에러가 발생했을 때 다시 시도하도록 유도하는 UI를 표시
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('서버와 연결을 실패했습니다.'),
                ElevatedButton(
                  onPressed: () => ref.refresh(stompClientProvider),
                  child: Text('다시 시도하기'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget stompLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    print("stompLoadedScreen");
    ref
        .read(storeInfoListNotifierProvider.notifier)
        .sendMyLocation(location.latitude, location.longitude);

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(location.locationName),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (String result) {
            if (result == 'changeLocation') {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationManagementScreen()))
                  .then((_) {
                // 위치 변경 후 HomeScreen으로 돌아왔을 때 필요한 로직 (예: 상태 업데이트)
              });
            } else if (result == 'nowLocation') {
              // 현재 위치로 변경
              print("nowLocation selected!!!!!!!!!!!!");
              _refreshCurrentLocation(context, ref);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'nowLocation',
              child: Text('현재 위치'),
            ),
            PopupMenuItem<String>(
              value: 'changeLocation',
              child: Text('위치 변경하기'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 위치 검색 로직
            },
          ),
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              // 즐겨찾기 페이지로 이동
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text('가게 목록', style: Theme.of(context).textTheme.headline6),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  // storeInfoListNotifierProvider에서 상태를 구독
                  final storeInfoList =
                      ref.watch(storeInfoListNotifierProvider);

                  return ListView.builder(
                    itemCount: storeInfoList.length,
                    itemBuilder: (context, index) {
                      final storeInfo = storeInfoList[index];
                      return InkWell(
                        onTap: () {
                          // 다음 페이지로 네비게이션
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StoreDetailInfoWidget(
                                      storeCode: storeInfo.storeCode)));
                          print(
                              'Navigating with storeCode: ${storeInfo.storeCode}');
                        },
                        child: ListTile(
                          title: Text(
                              '가게 ${storeInfo.storeCode}: ${storeInfo.storeName}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('주소: ${storeInfo.address}'),
                              Text('거리: ${storeInfo.distance}'),
                              Text('위도: ${storeInfo.latitude}'),
                              Text('경도: ${storeInfo.longitude}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;

  const CategoryItem({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chip(
        label: Text(title),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class StoreItem extends StatelessWidget {
  final String name;
  final String distance;

  const StoreItem({Key? key, required this.name, required this.distance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('거리: $distance'),
      onTap: () {
        // 가게 상세 페이지로 이동
      },
    );
  }
}
