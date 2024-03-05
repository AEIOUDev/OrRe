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

  // JSON에서 Dart 객체 생성자
  factory StoreWaitingInfo.fromJson(Map<String, dynamic> json) {
    return StoreWaitingInfo(
      storeCode: json['serverCode'],
      waitingQueue: [],
      lastWaitingNumber: json['lastWaitingNumber'],
      predictWaitingTime: json['predictWaitingTime'],
    );
  }
}

final storeWaitingInfoStreamProvider =
    StreamProvider.family<StoreWaitingInfo, String>((ref, storeCode) {
  final Uri websocketUri = Uri.parse('ws://192.168.1.214:8080/ws');
  final channel = WebSocketChannel.connect(websocketUri);

  // 일단, 웹소켓에 접속 후 storeCode를 메세지로 보내서, 응답으로 현재 웨이팅 정보가 오게끔 유도
  // final message = jsonEncode({'storeCode': storeCode});
  // channel.sink.add(message);

  // 서버에 연결 요청
  channel.sink.add('CONNECT\naccept-version:1.1,1.0\n\n\x00');

  // 웹소켓 스트림을 리슨하고, JSON 데이터를 StoreWaitingInfo 객체로 변환함
  // Null이 들어오게 되면 에러가 나게 되는데, 서버 단에서 Null을 보내지 않도록 하거나 여기서 처리해야 함

  channel.stream.listen((data) {
    print('Received: $data');
    // WaitingTime 정보 요청 및 처리
    if (data.contains('CONNECTED')) {
      print('Connected to the server.');
      // 연결 성공 후, /topic/waitingTimeInfo 주제에 구독
      channel.sink.add(
          'SUBSCRIBE\nid:sub-1\ndestination:/topic/waitingTimeInfo\n\n\x00');
      // 연결 성공 후 즉시 /waitingTimeInfoRequest 요청을 보내야 함
      channel.sink.add('SEND\ndestination:/app/waitingTimeInfoRequest\n\n\x00');
    } else if (data.contains('MESSAGE')) {
      //topic/waitingTimeInfo로부터 메시지 수신 확인
      if (data.contains('destination:/topic/waitingTimeInfo')) {
        final payloadStart = data.indexOf('\n\n') + 2;
        var payload = data.substring(payloadStart).trim();
        payload = payload.replaceAll('\x00', '');
        try {
          // 수신된 메시지 처리 (예: JSON 파싱)
          final messageData = json.decode(payload);
          // JSON 문자열을 Waitingtime 객체로 변환
          final waitingTime = StoreWaitingInfo.fromJson(messageData);
          // 객체 필드에 접근하여 출력
          print('Server Code 2: ${waitingTime.storeCode}');
          print('Last Waiting Number: ${waitingTime.lastWaitingNumber}');
          print('Predict Waiting Time: ${waitingTime.predictWaitingTime}');
        } catch (e) {
          print('Error parsing JSON: $e');
          print('Original payload: $payload');
        }
      }
    }
  });

  return channel.stream.map((data) {
    print(data);
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
