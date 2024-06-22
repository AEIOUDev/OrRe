import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/main.dart';
import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../model/store_service_log_model.dart';
import '../../services/debug_services.dart';
import '../../widget/background/waveform_background_widget.dart';

class ServiceLogScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo == null) {
      // 유저 정보 없음
      printd("유저 정보 없음, UserInfoCheckWidget() 호출");
      return UserInfoCheckWidget();
    } else {
      // 유저 정보 있음
      printd("유저 정보 존재 : ${userInfo.phoneNumber}");
      printd("ServiceLogWidget() 호출");
      return FutureBuilder(
        future: ref
            .watch(serviceLogProvider.notifier)
            .fetchStoreServiceLog(userInfo.phoneNumber),
        builder: (context, snapshot) {
          ServiceLogResponse serviceLogResponse;
          if (snapshot.data == null) {
            return CustomLoadingIndicator(
              message: "서비스 정보를 불러오는 중",
            );
          } else {
            serviceLogResponse = snapshot.data as ServiceLogResponse;
          }
          return WaveformBackgroundWidget(
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(0.25.sh),
                child: StaticAppBarWidget(
                  title: "이용내역 조회",
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
              ),
              body: (serviceLogResponse.userLogs.isEmpty)
                  ? Center(
                      child: TextWidget(
                        "이용내역이 없습니다.",
                        fontSize: 32.sp,
                        color: Colors.grey,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: serviceLogResponse.userLogs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            TextWidget("index : $index",
                                textAlign: TextAlign.left,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold),
                            TextWidget(
                                "historyId : " +
                                    serviceLogResponse
                                        .userLogs[index].historyNum
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Status : " +
                                    serviceLogResponse.userLogs[index].status
                                        .toKr(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Make Waiting Time : " +
                                    serviceLogResponse
                                        .userLogs[index].makeWaitingTime
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Store Code : " +
                                    serviceLogResponse.userLogs[index].storeCode
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Status Change Time : " +
                                    serviceLogResponse
                                        .userLogs[index].statusChangeTime
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Paid Money : " +
                                    serviceLogResponse.userLogs[index].paidMoney
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Ordered Menu : " +
                                    serviceLogResponse
                                        .userLogs[index].orderedMenu
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "User Phone Number : " +
                                    serviceLogResponse
                                        .userLogs[index].userPhoneNumber,
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "User Waiting Number : " +
                                    serviceLogResponse.userLogs[index].waiting
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            TextWidget(
                                "Waiting Person Number : " +
                                    serviceLogResponse
                                        .userLogs[index].personNumber
                                        .toString(),
                                textAlign: TextAlign.left,
                                fontSize: 16.sp),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
              backgroundColor: Colors.transparent,
            ),
          );
        },
      );
    }
  }
}
