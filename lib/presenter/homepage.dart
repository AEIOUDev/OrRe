import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/location_info_provider.dart';

import '../provider/location/location_securestorage_provider.dart';
import 'location/location_manager_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowLocation = ref.watch(locationProvider);
    final location = ref.watch(locationListProvider); // 선택된 위치

    print(location.selectedLocation?.locationName);
    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          // 현재 선택된 위치의 이름을 표시
          child: Text(location.selectedLocation?.locationName ?? '위치를 선택해주세요'),
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
              ref
                  .read(locationListProvider.notifier)
                  .selectLocation(location.nowLocation as LocationModel);
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '즐겨찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '웨이팅 리스트',
          ),
        ],
        currentIndex: 1, // 홈화면이 선택된 상태
        onTap: (index) {
          // 네비게이션 바 아이템 탭 로직
        },
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
