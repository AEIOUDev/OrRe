import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_detail_info_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/services/network/websocket_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../services/debug_services.dart';

final stompErrorStack = StateProvider<int>((ref) => 0);
final firstStompSetup = StateProvider<bool>((ref) => false);

enum StompStatus {
  CONNECTED,
  DISCONNECTED,
  ERROR,
}

final stompState = StateProvider<StompStatus>((ref) {
  return StompStatus.DISCONNECTED;
});

final stompClientStateNotifierProvider =
    StateNotifierProvider<StompClientStateNotifier, StompClient?>((ref) {
  return StompClientStateNotifier(ref);
});

class StompClientStateNotifier extends StateNotifier<StompClient?> {
  final Ref ref;
  late StompClient client;
  StompClientStateNotifier(this.ref) : super(null) {}

  Stream<StompStatus> configureClient() {
    printd("configureClient");
    final streamController = StreamController<StompStatus>.broadcast();

    if (state != null) {
      // 이미 configureClient가 실행되었을 경우 재설정 하지 않음
      return streamController.stream;
    } else {
      client = StompClient(
        config: StompConfig(
          url: WebSocketService.url,
          onConnect: (StompFrame frame) {
            printd("websocket connected");
            final firstBoot = ref.read(firstStompSetup.notifier).state;
            ref.read(stompState.notifier).state = StompStatus.CONNECTED;
            streamController.add(StompStatus.CONNECTED);
            if (firstBoot == true) {
              printd("already firstboot, fetchStoreServiceLog start");
              ref.read(stompErrorStack.notifier).state = 0;
            } else {
              onConnectCallback(frame);
            }
          },
          onWebSocketError: (dynamic error) {
            printd("websocket error: $error");
            // 연결 실패 시 0.5초 후 재시도
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onDisconnect: (_) {
            printd('websocket disconnected');
            // 연결 끊김 시 0.5초 후 재시도
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onStompError: (p0) {
            printd("websocket stomp error: $p0");
            // 연결 실패 시 0.5초 후 재시도
            streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onWebSocketDone: () {
            ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
            printd("websocket done");
            // 연결 끊김 시 재시도 로직
            if (ref
                .read(errorStateNotifierProvider.notifier)
                .state
                .contains(Error.network)) {
              return;
            }
            // 연결 실패 시 0.5초 후 재시도
            // streamController.add(reconnectionCallback(StompStatus.ERROR));
          },
          onDebugMessage: ((p0) {
            printd("websocket debug message: $p0");
          }),
        ),
      );

      Future.delayed(Duration(milliseconds: 10), () {
        client.activate();
        state = client;
      });
    }
    return streamController.stream;
  }

  void onConnectCallback(StompFrame connectFrame) {
    printd("웹소켓 연결 성공");
    ref.read(stompErrorStack.notifier).state = 0;
    ref.read(firstStompSetup.notifier).state = true;

    // 필요한 초기화 수행
    // 예를 들어, 여기서 다시 구독 로직을 실행
    ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(client);
    ref.read(storeWaitingRequestNotifierProvider.notifier).setClient(client);
    ref.read(storeWaitingUserCallNotifierProvider.notifier).setClient(client);
    ref.read(storeDetailInfoWebsocketProvider.notifier).setClient(client);
  }

  // void reconnect() {
  //   printd("reconnected");
  //   // 재시도 시, 구독 로직을 다시 실행
  //   if (ref
  //       .read(errorStateNotifierProvider.notifier)
  //       .state
  //       .contains(Error.network)) {
  //     return;
  //   }
  //   state?.activate();
  //   ref.read(storeWaitingInfoNotifierProvider.notifier).reconnect();
  //   ref.read(storeWaitingRequestNotifierProvider.notifier).reconnect();
  //   ref.read(storeWaitingUserCallNotifierProvider.notifier).reconnect();
  // }

  StompStatus reconnectionCallback(StompStatus status) {
    printd("reconnectionCallback");
    if (ref
        .read(errorStateNotifierProvider.notifier)
        .state
        .contains(Error.network)) {
      return status;
    }
    if (ref.read(stompErrorStack.notifier).state == 5) {
      return status;
    }
    ref.read(stompState.notifier).state = status;

    Future.delayed(Duration(milliseconds: 500), () {
      printd("웹소켓 재시도");
      state?.activate();
      ref.read(stompErrorStack.notifier).state++;
    });
    return status;
  }

  Future<void> reactive() async {
    printd("websocket reactive");
    state?.deactivate();
    state?.activate();
  }

  Future<void> disconnect() async {
    state?.deactivate();
    state = null;
  }
}
