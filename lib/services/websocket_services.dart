import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/location_model.dart';
import '../model/menu_info_model.dart';
import '../model/store_info_model.dart';
import '../model/user_info_model.dart';

class WebSocketManager with WidgetsBindingObserver {
  WebSocket? _webSocket;
  final String _serverUrl = 'ws://your_server_address';

  Future<void> connect() async {
    try {
      _webSocket = await WebSocket.connect(_serverUrl);
      _webSocket!.listen(_onMessage, onDone: _onDone, onError: _onError);
      print('WebSocket connected');
    } catch (e) {
      print('WebSocket connect error: $e');
    }
  }

  void disconnect() {
    _webSocket?.close();
    print('WebSocket disconnected');
  }

  void _onMessage(dynamic message) {
    // 서버로부터 메시지 수신 처리
    print('Received message: $message');
  }

  void _onDone() {
    print('WebSocket connection closed');
    // 자동 재연결 로직이 필요한 경우 여기에 구현
  }

  void _onError(error) {
    print('WebSocket error: $error');
    // 자동 재연결 로직이 필요한 경우 여기에 구현
  }

  void send(String message) {
    if (_webSocket != null) {
      _webSocket!.add(message);
      print('Sent message: $message');
    }
  }
}

class MyWaitingStateNotifier extends StateNotifier<List<UserWaitingStoreInfo>>
    with WidgetsBindingObserver {
  WebSocketManager _webSocketManager = WebSocketManager();

  MyWaitingStateNotifier() : super([]) {
    WidgetsBinding.instance.addObserver(this);
    _webSocketManager.connect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webSocketManager.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _webSocketManager.connect();
    } else if (state == AppLifecycleState.paused) {
      _webSocketManager.disconnect();
    }
  }

  void requestWaiting(String storeCode, UserSimpleInfo userSimpleInfo) {
    // 웨이팅 요청 데이터를 JSON 형식으로 변환하여 서버에 전송
    final requestData = jsonEncode({
      'action': 'requestWaiting',
      'storeCode': storeCode,
      'userInfo': {
        'name': userSimpleInfo.name,
        'phoneNumber': userSimpleInfo.phoneNumber,
        'numberOfUs': userSimpleInfo.numberOfUs
      }
    });
    _webSocketManager.send(requestData);

    // 이후 서버로부터 응답을 받으면 _webSocketManager._onMessage에서 처리
  }
}
