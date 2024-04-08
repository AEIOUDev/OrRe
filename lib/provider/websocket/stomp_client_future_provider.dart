// stomp_client_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/websocket/store_waiting_info_list_state_notifier.dart';
import 'package:orre/provider/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../services/websocket_services.dart';
import 'store_info_state_notifier.dart';
import 'store_location_list_state_notifier.dart';
import 'store_waiting_usercall_list_state_notifier.dart';

final stompClientProvider = FutureProvider<StompClient>((ref) async {
  final completer = Completer<StompClient>();
  late StompClient client;

  client = StompClient(
    config: StompConfig(
      url: WebSocketService.url,
      onConnect: (StompFrame frame) {
        print("connected");
        // 필요한 초기화 수행, 여기서 client는 이미 정의되어 있으므로 사용 가능합니다.
        ref.read(storeInfoListNotifierProvider.notifier).setClient(client);
        ref.read(storeInfoProvider.notifier).setClient(client);
        ref.read(storeWaitingInfoNotifierProvider.notifier).setClient(client);
        ref
            .read(storeWaitingRequestNotifierProvider.notifier)
            .setClient(client);
        ref
            .read(storeWaitingUserCallNotifierProvider.notifier)
            .setClient(client);
        completer.complete(client);
      },
      beforeConnect: () async {
        print('Connecting to websocket...');
      },
      onWebSocketError: (dynamic error) {
        print("websocket error");
        print(error.toString());
        completer.completeError(error);
        Future.delayed(Duration(seconds: 1)); // 2초 후 재시도
        client.activate();
      },
      onStompError: (dynamic error) {
        print("stomp error");
        print(error.toString());
        completer.completeError(error);
        Future.delayed(Duration(seconds: 1)); // 2초 후 재시도
        client.activate();
      },
      onDisconnect: (_) {
        print('disconnected');
        completer.completeError('disconnected');
        Future.delayed(Duration(seconds: 1)); // 2초 후 재시도
        client.activate();
      },
    ),
  );

  client.activate();
  return completer.future; // onConnect에서 complete가 호출될 때까지 대기합니다.
});
