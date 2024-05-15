import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/error/server_error_screen.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class WebsocketErrorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stomp = ref.watch(stompClientStateNotifierProvider);
    final stompStack = ref.watch(stompErrorStack);
    final networkError = ref.watch(networkStateNotifierProvider);

    print("ServerErrorScreen : $stompStack");
    // 네트워크 연결은 정상이나 웹소켓 연결을 5번 이상 실패했을 경우
    if (stompStack > 5 && networkError == true) {
      // 서버 에러로 판단하여 서버 에러 화면으로 이동
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ServerErrorScreen()));
    } else {
      print("다시 시도하기");
      ref.read(stompClientStateNotifierProvider.notifier).state?.activate();
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget('웹소켓을 불러오는데 실패했습니다.'),
            ElevatedButton(
              onPressed: () {
                print("다시 시도하기");
                ref.read(stompErrorStack.notifier).state = 0;
                ref
                    .read(stompClientStateNotifierProvider.notifier)
                    .state
                    ?.activate();
              },
              child: TextWidget('다시 시도하기'),
            ),
          ],
        ),
      ),
    );
  }
}
