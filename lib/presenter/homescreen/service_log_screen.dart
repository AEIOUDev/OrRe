import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';

class ServiceLogScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceLog = ref.watch(serviceLogProvider);
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo == null && userInfo?.phoneNumber != '') {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Service Log'),
        ),
        body: FutureBuilder(
          future: ref
              .read(serviceLogProvider.notifier)
              .fetchStoreServiceLog(userInfo!.phoneNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              // Render your UI based on the fetched data
              return ListView.builder(
                itemCount: serviceLog.userLogs.length,
                itemBuilder: (context, index) {
                  final log = serviceLog.userLogs[index];
                  return Column(children: [
                    Text('User Phone Number: ${log.userPhoneNumber}'),
                    Text('History Number: ${log.historyNum}'),
                    Text('Status: ${log.status}'),
                    Text('Make Waiting Time: ${log.makeWaitingTime}'),
                    Text('Store Code: ${log.storeCode}'),
                    Text('Status Change Time: ${log.statusChangeTime}'),
                    Text('Paid Money: ${log.paidMoney}'),
                    Text('Ordered Menu: ${log.orderedMenu}'),
                  ]);
                },
              );
            }
          },
        ),
      );
    }
  }
}
