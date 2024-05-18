import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/main.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/error/error_screen.dart';
import 'package:orre/presenter/homescreen/home_screen_store_list.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../../provider/home_screen/store_category_provider.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import 'home_screen_appbar.dart';
import 'home_screen_category_widget.dart';

class HomeScreen extends ConsumerWidget {
  @override
  // 위치 권한을 요청하고, 위치 정보를 불러오는 프로바이더를 사용하여 화면을 구성
  Widget build(BuildContext context, WidgetRef ref) {
    // 데이터가 정상적으로 로드되었을 때 UI를 표시
    final location = ref.watch(locationListProvider
        .select((value) => value.selectedLocation)); // 선택된 위치
    final nowLocationName = location?.locationName;
    print("nowLocationAsyncValue : " + (nowLocationName ?? ""));
    return locationLoadedScreen(
        context, ref, location ?? LocationInfo.nullValue());
  }

  // 위치 데이터가 정상적으로 로드되었을 때 가게 목록을 요청하는 화면을 구성
  Widget locationLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    final stomp = ref.watch(stompState);
    print("locationLoadedScreen");

    if (stomp == StompStatus.CONNECTED) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.websocket);
        if (ref.read(firstStoreWaitingListLoaded.notifier).state == true) {
          print("reconnect and reload storeWaitingInfoList");
          ref.read(storeWaitingInfoNotifierProvider.notifier).reconnect();
        } else {
          print("firstStoreWaitingListLoaded");
          ref.read(firstStoreWaitingListLoaded.notifier).state = true;
        }
      });
      print("stomp : ${stomp}");
    } else {
      print("stomp : ${stomp}");
      Future.delayed(Duration.zero, () {
        ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
      });
      return NetworkCheckScreen();
    }
    return stompLoadedScreen(context, ref, location);
  }

  // 가게 데이터가 정상적으로 로드되어 화면을 구성
  Widget stompLoadedScreen(
      BuildContext context, WidgetRef ref, LocationInfo location) {
    print("stompLoadedScreen");
    final nowCategory = ref.watch(selectCategoryProvider);
    final storeList = ref
        .watch(storeListProvider)
        .where((store) =>
            store.storeCategory == nowCategory.toKoKr() ||
            nowCategory == StoreCategory.all)
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFDFDFDF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HomeScreenAppBar(location: location),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryWidget(location: location),
            SizedBox(height: 20),
            Container(
              color: Colors.white,
              child: StoreListWidget(storeList: storeList),
            ),
          ],
        ),
      ),
    );
  }
}
