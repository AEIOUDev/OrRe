import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/services/network/websocket_services.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

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
  StompClientStateNotifier(this.ref) : super(null) {
    configureClient();
  }

  Stream<StompStatus> configureClient() {
    print("configureClient");
    final streamController = StreamController<StompStatus>.broadcast();

    client = StompClient(
      config: StompConfig(
        url: WebSocketService.url,
        onConnect: (StompFrame frame) {
          onConnectCallback(frame);
          ref.read(stompState.notifier).state = StompStatus.CONNECTED;
          streamController.add(StompStatus.CONNECTED);
        },
        onWebSocketError: (dynamic error) {
          print("websocket error: $error");
          // 연결 실패 시 0.5초 후 재시도
          ref.read(stompState.notifier).state = StompStatus.ERROR;
          streamController.add(StompStatus.ERROR);
          Future.delayed(Duration(milliseconds: 500), () {
            client.activate();
          });
        },
        onDisconnect: (_) {
          print('disconnected');
          // 연결 끊김 시 재시도 로직

          ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
          streamController.add(StompStatus.DISCONNECTED);
          Future.delayed(Duration(milliseconds: 500), () {
            client.activate();
          });
        },
        onStompError: (p0) {
          print("stomp error: $p0");
          ref.read(stompState.notifier).state = StompStatus.ERROR;
          streamController.add(StompStatus.ERROR);
          // 연결 실패 시 재시도 로직
          Future.delayed(Duration(milliseconds: 500), () {
            client.activate();
          });
        },
        onDebugMessage: (p0) {
          print("debug message: $p0");
        },
        onWebSocketDone: () {
          ref.read(stompState.notifier).state = StompStatus.DISCONNECTED;
          streamController.close();
          print("websocket done");
          // 연결 끊김 시 재시도 로직
        },
      ),
    );

    Future.delayed(Duration(milliseconds: 100), () {
      client.activate();
      state = client;
    });
    return streamController.stream;
  }

  // Add your state management methods here

  // Example method to connect to the STOMP server
  void onConnectCallback(StompFrame connectFrame) {
    // client is connected and ready
    // Implement your connection logic here

    print("connected");

    // 필요한 초기화 수행
    // 예를 들어, 여기서 다시 구독 로직을 실행
    ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(client);
    ref.read(storeWaitingRequestNotifierProvider.notifier).setClient(client);
    ref.read(storeWaitingUserCallNotifierProvider.notifier).setClient(client);
  }

  void reconnect() {
    print("reconnected");
    // 재시도 시, 구독 로직을 다시 실행
    if (ref
        .read(errorStateNotifierProvider.notifier)
        .state
        .contains(Error.network)) {
      return;
    }
    state?.activate();
    ref.read(storeWaitingInfoNotifierProvider.notifier).reconnect();
    ref.read(storeWaitingRequestNotifierProvider.notifier).reconnect();
    ref.read(storeWaitingUserCallNotifierProvider.notifier).reconnect();
    ref.read(stompState.notifier).state = StompStatus.CONNECTED;
  }

  // Example method to disconnect from the STOMP server
  Future<void> disconnect() async {
    // Implement your disconnection logic here
    client.deactivate();
  }
}
