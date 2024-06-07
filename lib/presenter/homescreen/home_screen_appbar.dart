import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/services/notifications_services.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug.services.dart';

class HomeScreenAppBar extends ConsumerWidget {
  final LocationInfo location;

  const HomeScreenAppBar({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        height: 300,
        color: Colors.transparent,
        child: AppBar(
          toolbarHeight: 58.h,
          title: GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(location.locationName, fontSize: 20.sp),
                Icon(Icons.arrow_drop_down, size: 20.sp),
              ],
            ),
            onTap: () {
              context.push('/location/locationManagement');
            },
          ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.search,
            //     color: Colors.black,
            //   ),
            //   onPressed: () {
            //     // 가게 검색 로직
            //     printdd("임시로 Store Info 1로 이동");
            //     context.push('/storeinfo/1');
            //   },
            // ),
            IconButton(
              icon: Icon(
                Icons.star,
                color: Colors.black,
                size: 20.sp,
              ),
              onPressed: () {
                printd("즐겨찾기 페이지로 이동이지만 지금은 이스터에그");
                // 즐겨찾기 페이지로 이동
                NotificationService.showNotification(
                    NotificationType.easteregg);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
                size: 20.sp,
              ),
              onPressed: () {
                // 설정 페이지로 이동
                context.push("/setting");
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
}
