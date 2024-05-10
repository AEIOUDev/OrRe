import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/homescreen/home_screen_store_list.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import '../../provider/home_screen/store_category_provider.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../provider/store_list_state_notifier.dart';
import 'home_screen_appbar.dart';
import 'home_screen_category_widget.dart';

class HomeScreen extends ConsumerWidget {
  @override
  // HomeScreen의 build 메서드는 네트워크 정보를 불러오는 화면을 구성
  Widget build(BuildContext context, WidgetRef ref) {
    final network = ref.watch(networkStreamProvider);

    return network.when(
      data: (data) {
        print("networkLoadedScreen : $data");
        if (data) {
          return networkLoadedScreen(context, ref);
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('네트워크 정보를 불러오는데 실패했습니다.'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(networkStreamProvider),
                    child: Text('다시 시도하기'),
                  ),
                ],
              ),
            ),
          );
        }
      },
      error: (error, stack) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('네트워크 정보를 불러오는데 실패했습니다.'),
                ElevatedButton(
                  onPressed: () => ref.refresh(networkStreamProvider),
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

  // 위치 정보를 불러오는 프로바이더를 사용하여 화면을 구성
  Widget networkLoadedScreen(BuildContext context, WidgetRef ref) {
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

  // 위치 데이터가 정상적으로 로드되었을 때 가게 목록을 요청하는 화면을 구성
  Widget locationLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    final stomp = ref.watch(stompState);
    print("locationLoadedScreen");

    if (stomp == StompStatus.CONNECTED) {
      print("stomp : ${stomp}");
      return stompLoadedScreen(context, ref, location);
    } else if (stomp == StompStatus.DISCONNECTED) {
      Future.delayed(Duration.zero, () {
        ref.read(stompClientStateNotifierProvider)?.activate;
      });
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('서버와 연결을 실패했습니다.'),
              ElevatedButton(
                onPressed: () => ref.refresh(stompClientStateNotifierProvider),
                child: Text('다시 시도하기'),
              ),
            ],
          ),
        ),
      );
    } else if (stomp == StompStatus.ERROR) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('서버와 연결을 실패했습니다.'),
              ElevatedButton(
                onPressed: () => ref.refresh(stompClientStateNotifierProvider),
                child: Text('다시 시도하기'),
              ),
            ],
          ),
        ),
      );
    } else {
      print("stomp : ${stomp}");
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('서버와 연결 중...'),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    ;
  }

  // 가게 데이터가 정상적으로 로드되어 화면을 구성
  Widget stompLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    final nowCategory = ref.watch(selectCategoryProvider);
    final storeList = ref
        .watch(storeListProvider)
        .where((store) =>
            store.storeCategory == nowCategory.toKoKr() ||
            nowCategory == StoreCategory.all)
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HomeScreenAppBar(location: location),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryWidget(location: location),
              StoreListWidget(storeList: storeList),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
