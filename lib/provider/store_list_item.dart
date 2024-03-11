import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/home_screen.dart';

class Msg {
  String type;
  int roomId;
  int senderId;
  String detailMessage;
  String senderName;

  Msg(
      {required this.type,
      required this.roomId,
      required this.senderId,
      required this.detailMessage,
      required this.senderName});
}

class LocationInfoSimple {
  double latitude;
  double longitude;

  LocationInfoSimple({
    required this.latitude,
    required this.longitude,
  });
}

final messagesProvider = StateProvider<List<Msg>>((ref) => []);

class StompClientNotifier extends StateNotifier<List<Msg>> {
  StompClientNotifier() : super([]);

  late StompClient stompClient;

  void setupStompClient() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://192.168.1.214:8080/ws',
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );

    stompClient.activate();
  }

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/nearestStores',
      callback: (frame) {
        print("!!!");
        List<dynamic>? result = json.decode(frame.body!);
        print(result);
        Map<String, dynamic> obj = json.decode(frame.body!);
        print(obj);
        Msg message = Msg(
          detailMessage: obj['detailMessage'],
          roomId: obj['roomId'],
          senderId: obj['senderId'],
          senderName: obj['senderName'],
          type: obj['type'],
        );
        state = [...state, message];
      },
    );
    sendMessage(LocationInfoSimple(latitude: 34, longitude: 127));
  }

  void sendMessage(LocationInfoSimple message) {
    stompClient.send(
      destination: '/app/nearestStores',
      body: json.encode({
        "latitude": message.latitude,
        "longitude": message.longitude,
      }),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }
}

final stompClientProvider =
    StateNotifierProvider<StompClientNotifier, List<Msg>>((ref) {
  return StompClientNotifier();
});
