import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// 모델
class StoreInfoInList {
  final String storeCode;
  final String storeName;
  final int distanceFromUser;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;

  StoreInfoInList({
    required this.storeCode,
    required this.storeName,
    required this.distanceFromUser,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
  });

  factory StoreInfoInList.fromJson(Map<String, dynamic> json) {
    return StoreInfoInList(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      distanceFromUser: json['distanceFromUser'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
    );
  }
}

// Notifier
class WebSocketNotifier extends StateNotifier<List<StoreInfoInList>> {
  WebSocketChannel? _channel;
  WebSocketNotifier() : super([]) {
    _connect();
  }

  void _connect() {
    _channel =
        WebSocketChannel.connect(Uri.parse('ws://myknow.xyz/ws/storelist/'));
    _channel!.stream.listen((data) {
      state = (json.decode(data) as List)
          .map<StoreInfoInList>((item) => StoreInfoInList.fromJson(item))
          .toList();
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

// Provider
final webSocketProvider =
    StateNotifierProvider<WebSocketNotifier, List<StoreInfoInList>>((ref) {
  return WebSocketNotifier();
});
