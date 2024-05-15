import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/location/location_manager_screen.dart';
import 'package:orre/presenter/homescreen/setting_screen.dart';
import 'package:orre/provider/location/now_location_provider.dart';

import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class HomeScreenAppBar extends ConsumerWidget {
  final LocationInfo location;

  const HomeScreenAppBar({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = StoreListParameters(
        sortType: ref.watch(selectSortTypeProvider),
        latitude: location.latitude,
        longitude: location.longitude);
    if (ref.read(storeListProvider.notifier).isExistRequest(params)) {
      print("storeListProvider isExistRequest");
    } else {
      print("storeListProvider fetchStoreDetailInfo");
      ref.read(storeListProvider.notifier).fetchStoreDetailInfo(params);
    }

    // final watchState = ref.watch(stompState);

    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: TextWidget('stompState : {$watchState}')));

    return Container(
        height: 300,
        color: Colors.transparent,
        child: AppBar(
          title: PopupMenuButton<String>(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(location.locationName),
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
                child: TextWidget('현재 위치'),
              ),
              PopupMenuItem<String>(
                value: 'changeLocation',
                child: TextWidget('위치 변경하기'),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {
                // 위치 검색 로직
              },
            ),
            IconButton(
              icon: Icon(
                Icons.star,
                color: Colors.black,
              ),
              onPressed: () {
                // 즐겨찾기 페이지로 이동
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                // 설정 페이지로 이동
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingScreen()));
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Color(0xFFFFB74D),
        ));
  }

  // 현재 위치를 새로고침하는 메소드
  void _refreshCurrentLocation(BuildContext context, WidgetRef ref) async {
    print("_refreshCurrentLocation");
    try {
      // nowLocationProvider를 refresh하고 결과를 기다립니다.
      ref
          .refresh(nowLocationProvider.notifier)
          .updateNowLocation()
          .then((value) {
        // 결과를 출력합니다.
        print("updateNowLocation value : $value");
        // 성공적으로 위치 정보를 받았으면, 이를 LocationListProvider에 업데이트합니다.
        if (value != null) {
          ref.read(locationListProvider.notifier).updateNowLocation(value);
        } else {
          // 에러 처리...
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: TextWidget('현재 위치를 불러오는데 실패했습니다.')),
          );
        }
      });
    } catch (error) {
      // 에러 처리...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextWidget('현재 위치를 불러오는데 실패했습니다.')),
      );
    }
  }
}
