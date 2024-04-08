import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/websocket/store_waiting_info_list_state_notifier.dart';

import '../provider/home_screen/store_category_provider.dart';
import '../provider/home_screen/store_list_sort_type_provider.dart';
import '../provider/location/location_securestorage_provider.dart';
import '../provider/websocket/stomp_client_future_provider.dart';
import '../provider/websocket/store_location_list_state_notifier.dart';
import 'location/location_manager_screen.dart';
import 'store_info_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  // 위치 정보를 불러오는 프로바이더를 사용하여 화면을 구성
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

  // 위치 데이터가 정상적으로 로드되었을 때 가게 목록을 요청하는 화면을 구성
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

  // 가게 데이터가 정상적으로 로드되어 화면을 구성할 때
  Widget stompLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    final nowCategory = ref.watch(selecteCategoryProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HomeScreenAppBar(location: location),
      ),
      body: Center(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(children: [
                Row(
                  children: [
                    CategoryItem(category: StoreCategory.all),
                    CategoryItem(category: StoreCategory.korean),
                    CategoryItem(category: StoreCategory.chinese),
                    CategoryItem(category: StoreCategory.japanese),
                  ],
                ),
                Row(
                  children: [
                    CategoryItem(category: StoreCategory.western),
                    CategoryItem(category: StoreCategory.snack),
                    CategoryItem(category: StoreCategory.cafe),
                    CategoryItem(category: StoreCategory.etc),
                  ],
                ),
              ]),
            ),
            Row(
              children: [
                Text(nowCategory.toKoKr(),
                    style: Theme.of(context).textTheme.headline6),
                Spacer(),
                HomeScreenModalBottomSheet(location: location),
              ],
            ),
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
                      return StoreItem(
                        storeInfo: storeInfo,
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

class HomeScreenAppBar extends ConsumerWidget {
  final LocationInfo location;

  const HomeScreenAppBar({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(storeInfoListNotifierProvider.notifier)
        .sendMyLocation(location.latitude, location.longitude);
    return AppBar(
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
    );
  }

  // 현재 위치를 새로고침하는 메소드
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
}

class HomeScreenModalBottomSheet extends ConsumerWidget {
  final LocationInfo location;
  const HomeScreenModalBottomSheet({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowSortType = ref.watch(selecteSortTypeProvider);

    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(StoreListSortType.basic.toKoKr()),
                    trailing: nowSortType == StoreListSortType.basic
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref
                          .read(storeInfoListNotifierProvider.notifier)
                          .changeSortType(StoreListSortType.basic, location);
                      Navigator.pop(context);
                    },
                  ),
                  // 아직 기능 안 함
                  ListTile(
                    title: Text(StoreListSortType.popular.toKoKr()),
                    trailing: nowSortType == StoreListSortType.popular
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selecteSortTypeProvider.notifier).state =
                          StoreListSortType.popular;
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(StoreListSortType.nearest.toKoKr()),
                    trailing: nowSortType == StoreListSortType.nearest
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref
                          .read(storeInfoListNotifierProvider.notifier)
                          .changeSortType(StoreListSortType.nearest, location);
                      Navigator.pop(context);
                    },
                  ),
                  // 아직 기능 안 함
                  ListTile(
                    title: Text(StoreListSortType.fast.toKoKr()),
                    trailing: nowSortType == StoreListSortType.fast
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selecteSortTypeProvider.notifier).state =
                          StoreListSortType.fast;
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text('닫기', style: TextStyle(color: Colors.black)),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          },
        );
      },
      child: Text(nowSortType.toKoKr()),
    );
  }
}

class CategoryItem extends ConsumerWidget {
  final StoreCategory category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTitle = ref.watch(selecteCategoryProvider);

    return ButtonBar(
      children: [
        ElevatedButton(
          onPressed: () {
            ref.read(selecteCategoryProvider.notifier).state = category;
            print("category : " +
                ref.read(selecteCategoryProvider.notifier).state.toKoKr());
          },
          child: Text(category.toKoKr()),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTitle == category ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class StoreItem extends ConsumerWidget {
  final StoreLocationInfo storeInfo;

  const StoreItem({Key? key, required this.storeInfo}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(storeWaitingInfoNotifierProvider.notifier)
        .subscribeToStoreWaitingInfo(storeInfo.storeCode);
    final storeWaitingInfo = ref.watch(
      storeWaitingInfoNotifierProvider.select((state) {
        // state를 StoreWaitingInfo의 리스트로 가정합니다.
        // storeInfo.storeCode와 일치하는 첫 번째 객체를 찾습니다.
        // print("storeInfo.storeCode : ${storeInfo.storeCode}");
        return state.firstWhere(
          (storeWaitingInfo) =>
              storeWaitingInfo.storeCode == storeInfo.storeCode,
          orElse: () => StoreWaitingInfo(
              storeCode: storeInfo.storeCode,
              waitingTeamList: [],
              enteringTeamList: [],
              estimatedWaitingTimePerTeam: 0), // 일치하는 객체가 없을 경우 0을 반환합니다.
        );
      }),
    );
    return InkWell(
      onTap: () {
        // 다음 페이지로 네비게이션
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StoreDetailInfoWidget(storeCode: storeInfo.storeCode)));
      },
      child: ListTile(
        leading: Image.network(storeInfo.storeImageMain, width: 50, height: 50),
        title: Text('가게 ${storeInfo.storeCode}: ${storeInfo.storeName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('주소: ${storeInfo.address}'),
            Text('거리: ${storeInfo.distance.round()}m'),
            // Text('위도: ${storeInfo.latitude}'),
            // Text('경도: ${storeInfo.longitude}'),
            Text('소개: ${storeInfo.storeShortIntroduce}'),
            Text("카테고리: ${storeInfo.storeCategory}"),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("대기팀 수: ${storeWaitingInfo.waitingTeamList.length}"),
            Text(
                "예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분"),
          ],
        ),
      ),
    );
  }
}
