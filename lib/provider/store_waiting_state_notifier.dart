import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StoreWaitingInfo {
  final String storeCode;
  final List<int> waitingQueue;
  final int lastWaitingNumber;
  final int predictWaitingTime;

  StoreWaitingInfo({
    required this.storeCode,
    required this.waitingQueue,
    required this.lastWaitingNumber,
    required this.predictWaitingTime,
  });
}

final storeWaitingInfoStreamProvider =
    StreamProvider.family<StoreWaitingInfo, String>((ref, storeCode) {
  final Uri websocketUri = Uri.parse('ws://192.168.1.214:8080/');
  final channel = WebSocketChannel.connect(websocketUri);

  // 일단, 웹소켓에 접속 후 storeCode를 메세지로 보내서, 응답으로 현재 웨이팅 정보가 오게끔 유도
  final message = jsonEncode({'storeCode': storeCode});
  channel.sink.add(message);

  // 웹소켓 스트림을 리슨하고, JSON 데이터를 StoreWaitingInfo 객체로 변환함
  // Null이 들어오게 되면 에러가 나게 되는데, 서버 단에서 Null을 보내지 않도록 하거나 여기서 처리해야 함
  return channel.stream.map((data) {
    final jsonData = jsonDecode(data);
    print(jsonData);
    return StoreWaitingInfo(
      storeCode: jsonData['storeCode'],
      waitingQueue: List<int>.from(jsonData['waitingQueue']),
      lastWaitingNumber: jsonData['lastWaitingNumber'],
      predictWaitingTime: jsonData['predictWaitingTime'],
    );
  });
});
