import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/location_info_provider.dart';

import '../provider/location/location_securestorage_provider.dart';
import '../provider/store_list_item.dart';
import 'location/location_manager_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowLocationAsyncValue = ref.watch(locationProvider);

    // AsyncValue를 사용하여 상태 처리
    return nowLocationAsyncValue.when(
      data: (data) {
        // 데이터가 정상적으로 로드되었을 때 UI를 표시
        final location = ref.watch(locationListProvider); // 선택된 위치
        return buildLoadedScreen(context, ref, location);
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
                  onPressed: () => ref.refresh(locationProvider),
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

// 데이터가 정상적으로 로드되었을 때 화면 구성
  Widget buildLoadedScreen(
      BuildContext context, WidgetRef ref, LocationState location) {
    final storeList = ref.watch(stompClientProvider.notifier);
    storeList.setupStompClient();

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          // 현재 선택된 위치의 이름을 표시
          child: Row(
            mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조절합니다.
            children: [
              Text(location.selectedLocation?.locationName ??
                  '위치를 선택해주세요'), // 여기에 원하는 텍스트를 입력하세요.
              Icon(Icons.arrow_drop_down), // arrow_drop_down 아이콘을 추가합니다.
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
              ref.refresh(locationProvider);
              ref
                  .read(locationListProvider.notifier)
                  .updateNowLocation(location.nowLocation as LocationInfo);
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
      body: Column(
        children: [
          // 가게 카테고리 섹션
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                CategoryItem(title: '식당'),
                CategoryItem(title: '팝업 스토어'),
                // 다른 카테고리 추가...
              ],
            ),
          ),
          // 근처 가게 리스트
          Expanded(
            child: ListView(
              children: <Widget>[
                StoreItem(name: '가게 1', distance: '1km'),
                StoreItem(name: '가게 2', distance: '2km'),
                // 더 많은 가게 아이템...
              ],
            ),
          ),
        ],
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
