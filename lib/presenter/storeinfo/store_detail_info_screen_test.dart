import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:orre/presenter/storeinfo/store_detail_info_screen.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';

class StoreDetailInfoTestScreen extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  const StoreDetailInfoTestScreen({Key? key, required this.storeDetailInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final network = ref.watch(networkStreamProvider);
    network.when(data: (value) {
      if (value) {
        showDialog(
          context: context,
          builder: (context) {
            // Add a return statement at the end of the builder function
            return AlertPopupWidget(
                title: "네트워크 연결 상태가 확인되었습니다.", buttonText: "확인");
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            // Add a return statement at the end of the builder function
            return AlertPopupWidget(title: "네트워크가 유실되었습니다.", buttonText: "확인");
          },
        );
      }
    }, loading: () {
      print('loading');
    }, error: (Object error, StackTrace stackTrace) {
      print('error');
    });

    return Scaffold(
      body: Text("test"),
    );
  }
}
