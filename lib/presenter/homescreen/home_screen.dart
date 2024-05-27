import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/homescreen/home_screen_store_list.dart';
import '../../model/store_list_model.dart';
import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import '../../services/debug.services.dart';
import 'home_screen_appbar.dart';
import 'home_screen_category_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late LocationInfo nowLocation;

  @override
  void initState() {
    printd("\n\nHomeScreen initState 진입");
    super.initState();
  }

  // @override
  // Future<void> didChangeDependencies() async {
  //   printd("\n\nHomeScreen didChangeDependencies 진입");

  //   // build 함수가 호출되기 전에 초기화 함수 실행
  //   final location = ref.watch(locationListProvider);
  //   final selectedLocation = location.selectedLocation;
  //   printd("selectedLocation : " + (selectedLocation?.locationName ?? "null"));
  //   nowLocation = selectedLocation ?? LocationInfo.nullValue();

  //   print("nowLocationAsyncValue : " + (nowLocation.locationName));

  //   final params = StoreListParameters(
  //       sortType: ref.watch(selectSortTypeProvider),
  //       latitude: nowLocation.latitude,
  //       longitude: nowLocation.longitude);
  //   if (ref.read(storeListProvider.notifier).isExistRequest(params)) {
  //     print("storeListProvider isExistRequest");
  //   } else {
  //     print("storeListProvider fetchStoreDetailInfo");
  //     await ref.read(storeListProvider.notifier).fetchStoreDetailInfo(params);
  //   }

  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // 위치 권한을 요청하고, 위치 정보를 불러오는 프로바이더를 사용하여 화면을 구성
  Widget build(BuildContext context) {
    printd("\n\nHomeScreen build 진입");
    // build 함수가 호출되기 전에 초기화 함수 실행
    final location = ref.watch(locationListProvider);
    final selectedLocation = location.selectedLocation;
    printd("selectedLocation : " + (selectedLocation?.locationName ?? "null"));
    nowLocation = selectedLocation ?? LocationInfo.nullValue();

    print("nowLocationAsyncValue : " + (nowLocation.locationName));

    final params = StoreListParameters(
        sortType: ref.watch(selectSortTypeProvider),
        latitude: nowLocation.latitude,
        longitude: nowLocation.longitude);
    if (ref.read(storeListProvider.notifier).isExistRequest(params)) {
      print("storeListProvider isExistRequest");
    } else {
      print("storeListProvider fetchStoreDetailInfo");
    }

    return FutureBuilder(
        future:
            ref.read(storeListProvider.notifier).fetchStoreDetailInfo(params),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildHomeScreen(snapshot.data as List<StoreLocationInfo>);
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _buildHomeScreen(List<StoreLocationInfo> storeList) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFDFDFDF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HomeScreenAppBar(location: nowLocation),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryWidget(location: nowLocation),
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
