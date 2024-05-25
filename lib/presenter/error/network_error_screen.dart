import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class NetworkErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget('네트워크 정보를 불러오는데 실패했습니다.'),
            ElevatedButton(
              onPressed: () {
                ref.read(networkStateProvider).listen((event) {
                  if (event) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      ref.refresh(stompClientStateNotifierProvider.notifier);
                    });
                  }
                });
              },
              child: TextWidget('다시 시도하기'),
            ),
          ],
        ),
      ),
    );
  }
}
