import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/main.dart';
import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';

class ServiceLogScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo == null) {
      // 유저 정보 없음
      print("유저 정보 없음, UserInfoCheckWidget() 호출");
      return UserInfoCheckWidget();
    } else {
      // 유저 정보 있음
      print("유저 정보 존재 : ${userInfo.phoneNumber}");
      print("ServiceLogWidget() 호출");
      return FutureBuilder(
        future: ref
            .watch(serviceLogProvider.notifier)
            .fetchStoreServiceLog(userInfo.phoneNumber),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CustomLoadingIndicator(),
            );
          }
          return Scaffold(
            body: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.userLogs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    TextWidget("index : $index",
                        textAlign: TextAlign.left,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                    TextWidget(
                        "historyId : " +
                            snapshot.data!.userLogs[index].historyNum
                                .toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Status : " +
                            snapshot.data!.userLogs[index].status.toKr(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Make Waiting Time : " +
                            snapshot.data!.userLogs[index].makeWaitingTime
                                .toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Store Code : " +
                            snapshot.data!.userLogs[index].storeCode.toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Status Change Time : " +
                            snapshot.data!.userLogs[index].statusChangeTime
                                .toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Paid Money : " +
                            snapshot.data!.userLogs[index].paidMoney.toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Ordered Menu : " +
                            snapshot.data!.userLogs[index].orderedMenu
                                .toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "User Phone Number : " +
                            snapshot.data!.userLogs[index].userPhoneNumber,
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "User Waiting Number : " +
                            snapshot.data!.userLogs[index].waiting.toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    TextWidget(
                        "Waiting Person Number : " +
                            snapshot.data!.userLogs[index].personNumber
                                .toString(),
                        textAlign: TextAlign.left,
                        fontSize: 16),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          );
        },
      );
    }
  }
}
