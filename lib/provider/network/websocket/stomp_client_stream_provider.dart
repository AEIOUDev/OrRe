// stomp_client_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../services/network/websocket_services.dart';
import 'store_waiting_usercall_list_state_notifier.dart';

final stompClientStreamProvider = StreamProvider<StompClient>((ref) {
  // StreamController를 생성합니다. broadcast를 사용하여 여러 리스너에서 구독 가능하도록 합니다.
  final streamController = StreamController<StompClient>.broadcast();
  late StompClient client;

  void connect() {
    // StompClient 구성
    client = StompClient(
      config: StompConfig(
        url: WebSocketService.url,
        onConnect: (StompFrame frame) {
          print("connected");
          // 필요한 초기화 수행
          // 예를 들어, 여기서 다시 구독 로직을 실행
          ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(client);
          ref
              .read(storeWaitingRequestNotifierProvider.notifier)
              .setClient(client);
          ref
              .read(storeWaitingUserCallNotifierProvider.notifier)
              .setClient(client);
          // 기타 등등...

          // 스트림에 StompClient를 추가합니다.
          streamController.add(client);
        },
        onWebSocketError: (dynamic error) {
          print("websocket error: $error");
          // 연결 실패 시 재시도 로직
          Future.delayed(Duration(seconds: 1), connect); // 1초 후 재시도
        },
        onDisconnect: (_) {
          print('disconnected');
          // 연결 끊김 시 재시도 로직
          Future.delayed(Duration(seconds: 1), connect); // 1초 후 재시도
        },
      ),
    );

    client.activate();
  }

  // 최초 연결 시도
  connect();

  return streamController.stream;
});
