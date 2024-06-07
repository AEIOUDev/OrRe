import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class HomeScreenModalBottomSheet extends ConsumerWidget {
  final LocationInfo location;
  const HomeScreenModalBottomSheet({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowSortType = ref.watch(selectSortTypeProvider);

    return SizedBox(
      width: 120.w,
      height: 40.h,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet<void>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      '목록',
                      style: TextStyle(
                        fontFamily: 'Dovemayo_gothic',
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 80,
                      height: 1,
                      color: Color(0xFFDFDFDF),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      title: TextWidget(
                        StoreListSortType.basic.toKoKr(),
                        fontSize: 20.sp,
                        color: nowSortType == StoreListSortType.basic
                            ? Color(0xFFFFBF52)
                            : Colors.black,
                        textAlign: TextAlign.start,
                      ),
                      trailing: nowSortType == StoreListSortType.basic
                          ? Icon(Icons.check, color: Color(0xFFFFBF52))
                          : Icon(Icons.check,
                              color: Color(0xFFFFFFFF).withOpacity(1)),
                      onTap: () {
                        ref.read(selectSortTypeProvider.notifier).state =
                            StoreListSortType.basic;
                        final params = StoreListParameters(
                            sortType: StoreListSortType.basic,
                            latitude: location.latitude,
                            longitude: location.longitude);
                        ref
                            .read(storeListProvider.notifier)
                            .fetchStoreDetailInfo(params);
                        context.pop();
                      },
                    ),
                    // 아직 기능 안 함
                    // ListTile(
                    //   title: TextWidget(
                    //     StoreListSortType.popular.toKoKr(),
                    //     color: nowSortType == StoreListSortType.popular
                    //         ? Color(0xFFFFBF52)
                    //         : Colors.black,
                    //     textAlign: TextAlign.start,
                    //   ),
                    //   trailing: nowSortType == StoreListSortType.popular
                    //       ? Icon(Icons.check, color: Color(0xFFFFBF52))
                    //       : Icon(Icons.check,
                    //           color: Color(0xFFFFFFFF).withOpacity(1)),
                    //   onTap: () {
                    //     ref.read(selectSortTypeProvider.notifier).state =
                    //         StoreListSortType.popular;
                    //     context.pop();
                    //   },
                    // ),
                    ListTile(
                      title: TextWidget(
                        StoreListSortType.nearest.toKoKr(),
                        color: nowSortType == StoreListSortType.nearest
                            ? Color(0xFFFFBF52)
                            : Colors.black,
                        textAlign: TextAlign.start,
                        fontSize: 20.sp,
                      ),
                      trailing: nowSortType == StoreListSortType.nearest
                          ? Icon(Icons.check, color: Color(0xFFFFBF52))
                          : Icon(Icons.check,
                              color: Color(0xFFFFFFFF).withOpacity(1)),
                      onTap: () {
                        ref.read(selectSortTypeProvider.notifier).state =
                            StoreListSortType.nearest;
                        final params = StoreListParameters(
                            sortType: StoreListSortType.nearest,
                            latitude: location.latitude,
                            longitude: location.longitude);
                        ref
                            .read(storeListProvider.notifier)
                            .fetchStoreDetailInfo(params);
                        context.pop();
                      },
                    ),
                    // 아직 기능 안 함
                    // ListTile(
                    //   title: TextWidget(
                    //     StoreListSortType.fast.toKoKr(),
                    //     color: nowSortType == StoreListSortType.fast
                    //         ? Color(0xFFFFBF52)
                    //         : Colors.black,
                    //     textAlign: TextAlign.start,
                    //   ),
                    //   trailing: nowSortType == StoreListSortType.fast
                    //       ? Icon(
                    //           Icons.check,
                    //           color: Color(0xFFFFBF52),
                    //         )
                    //       : Icon(Icons.check,
                    //           color: Color(0xFFFFFFFF).withOpacity(1)),
                    //   onTap: () {
                    //     ref.read(selectSortTypeProvider.notifier).state =
                    //         StoreListSortType.fast;
                    //     context.pop();
                    //   },
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 340,
                      height: 1,
                      color: Color(0xFFDFDFDF),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextButtonWidget(
                      text: '닫기',
                      fontSize: 24.sp,
                      onPressed: () => context.pop(),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), // 왼쪽 상단 모서리만 둥글게
              bottomLeft: Radius.circular(30), // 왼쪽 하단 모서리만 둥글게
            ),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          children: [
            TextWidget(nowSortType.toKoKr(), fontSize: 20.sp),
            Transform.rotate(
              angle: 90 * 3.14 / 180,
              child: Icon(
                Icons.sync_alt,
                color: Colors.black,
                size: 20.sp,
              ),
            )
          ],
        ),
      ),
    );
  }
}
