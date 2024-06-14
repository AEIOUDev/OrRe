import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/presenter/homescreen/home_screen_store_list.dart';
import 'package:orre/widget/background/extend_body_widget.dart';
import '../../provider/home_screen/store_category_provider.dart';
import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../provider/location/now_location_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import '../../services/debug_services.dart';
import '../../widget/loading_indicator/coustom_loading_indicator.dart';
import '../../widget/text/text_widget.dart';
import 'home_screen_appbar.dart';
import 'home_screen_category_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    printd("\n\nHomeScreen initState 진입");
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    printd("\n\nHomeScreen didChangeDependencies 진입");
    ref.watch(nowLocationProvider.notifier).updateNowLocation();
    super.didChangeDependencies();
  }

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
    LocationInfo finalLocation;
    if (selectedLocation == null) {
      printd("HomeScreen selectedLocation is null");
      if (location.nowLocation == null) {
        printd("HomeScreen nowLocation is null");
        finalLocation = LocationInfo.nullValue();
      } else {
        // 현재 위치 정보가 있을 때
        printd("HomeScreen nowLocation : ${location.nowLocation}");
        finalLocation = location.nowLocation!;
        ref.read(locationListProvider.notifier).selectLocationToNowLocation();
      }
    } else {
      printd("HomeScreen selectedLocation is not null : $selectedLocation");
      finalLocation = selectedLocation;
    }
    printd("selectedLocation : ${finalLocation}");

    print("nowLocationAsyncValue : " + (finalLocation.locationName));

    final params = StoreListParameters(
        sortType: ref.watch(selectSortTypeProvider),
        latitude: finalLocation.latitude,
        longitude: finalLocation.longitude);
    if (ref.read(storeListProvider.notifier).isExistRequest(params)) {
      print("storeListProvider isExistRequest");
    } else {
      print("storeListProvider fetchStoreDetailInfo");
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFDFDFDF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58.h),
        child: HomeScreenAppBar(location: finalLocation),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryWidget(location: finalLocation),
            SizedBox(height: 20),
            Container(
              child: Consumer(
                builder: (context, ref, child) {
                  return FutureBuilder(
                    future: ref
                        .read(storeListProvider.notifier)
                        .fetchStoreDetailInfo(params),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // 카테고리에 맞는 아이템만 골라서 리스트에 넣어주기
                        final nowCategory = ref.watch(selectCategoryProvider);
                        final filteredList = snapshot.data
                            ?.where((element) =>
                                element.storeCategory == nowCategory.toKoKr() ||
                                nowCategory.toKoKr() == "전체")
                            .toList();
                        if (filteredList == null || filteredList.isEmpty) {
                          return ExtendBodyWidget(
                            child: Container(
                              width: 0.95.sw,
                              padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/error_orre.gif",
                                    width: 200.w,
                                    height: 200.h,
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  TextWidget(
                                    "아직 주변에 등록된 가게가 없어요",
                                    textAlign: TextAlign.center,
                                    fontSize: 20.sp,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return StoreListWidget(storeList: filteredList);
                        }
                      } else {
                        return CustomLoadingIndicator(
                          message: "가게 정보를 불러오는 중..",
                        );
                      }
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
