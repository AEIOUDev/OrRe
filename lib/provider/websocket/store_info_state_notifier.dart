import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'package:http/http.dart' as http;

class StoreDetailInfo {
  final String storeImageMain;
  final int storeCode;
  final String storeName;
  final String storeIntroduce;
  final String storeCategory;
  final int storeInfoVersion;
  final int numberOfTeamsWaiting;
  final int estimatedWaitingTime;
  final List<dynamic> menuInfo;

  StoreDetailInfo({
    required this.storeImageMain,
    required this.storeCode,
    required this.storeName,
    required this.storeIntroduce,
    required this.storeCategory,
    required this.storeInfoVersion,
    required this.numberOfTeamsWaiting,
    required this.estimatedWaitingTime,
    required this.menuInfo,
  });

  factory StoreDetailInfo.fromJson(Map<String, dynamic> json) {
    return StoreDetailInfo(
      storeImageMain: json['storeImageMain'],
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeIntroduce: json['storeIntroduce'],
      storeCategory: json['storeCategory'],
      storeInfoVersion: json['storeInfoVersion'],
      numberOfTeamsWaiting: json['numberOfTeamsWaiting'],
      estimatedWaitingTime: json['estimatedWaitingTime'],
      menuInfo: json['menuInfo'],
    );
  }
}

Future<StoreDetailInfo> fetchStoreInfo(
    int storeCode, int storeTableNumber) async {
  print('fetchStoreInfo');
  final url = Uri.parse('https://orre.store/api/user/storeInfo');
  final body = {
    'storeCode': storeCode.toString(),
    'storeTableNumber': storeTableNumber.toString(),
  };
  final jsonBody = json.encode(body);
  print('jsonBody: $jsonBody');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    }, // Set the 'Content-Type' header to 'application/json; charset=UTF-8'
    body: jsonBody,
  );
  if (response.statusCode == 200) {
    final jsonBody = json.decode(utf8.decode(response.bodyBytes));
    print('jsonBody: $jsonBody');
    return StoreDetailInfo.fromJson(jsonBody);
  } else {
    print('response.statusCode: ${response.statusCode}');
    throw Exception('Failed to fetch store info');
  }
}

// StoreInfo 객체를 관리하는 프로바이더를 정의합니다.
final storeInfoProvider =
    StateNotifierProvider<StoreInfoNotifier, StoreDetailInfo?>((ref) {
  return StoreInfoNotifier(null); // 초기 상태를 null로 설정합니다.
});

// StateNotifier를 확장하여 StoreInfo 객체를 관리하는 클래스를 정의합니다.
class StoreInfoNotifier extends StateNotifier<StoreDetailInfo?> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  dynamic _unsubscribeFn; // 구독 해제 함수를 저장할 변수 추가

  StoreInfoNotifier(StoreDetailInfo? initialState) : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreInfo : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
  }

  void subscribeToStoreInfo(int storeCode) {
    if (_unsubscribeFn == null) {
      print("StoreInfo : subscribeToStoreInfo : $storeCode");
      _unsubscribeFn = _client?.subscribe(
        destination: '/topic/user/storeInfo',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            print("StoreInfo : subscribeToStoreInfo : ${frame.body}");
            try {
              // JSON 문자열을 파싱하여 StoreDetailInfo 객체로 변환
              final newInfo =
                  StoreDetailInfo.fromJson(json.decode(frame.body!));
              // 상태를 업데이트합니다.
              state = newInfo;
            } catch (e) {
              print("Error parsing store info: $e");
            }
          }
        },
      );
      print("StoreInfo : subscribe!");
      sendStoreCode(storeCode);
    } else {
      print("StoreInfo : already subscribed");
    }
  }

  // NFC 스캔 후 storeCode를 보내는 메서드
  void sendStoreCode(int storeCode) {
    print("StoreInfo : sendStoreCode : $storeCode");
    _client?.send(
      destination: '/app/user/storeInfo',
      body: json.encode({"storeCode": storeCode}),
    );
  }

  void unSubscribe() {
    print("StoreInfo : unSubscribe");
    if (_unsubscribeFn != null) {
      _unsubscribeFn(unsubscribeHeaders: null);
      _unsubscribeFn = null;
    }
  }

  @override
  void dispose() {
    unSubscribe();
    super.dispose();
  }
}
