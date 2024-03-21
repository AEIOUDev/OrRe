import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreLocationInfo {
  final int storeCode;
  final String storeName;
  final String address;
  final double distance;
  final double latitude;
  final double longitude;

  StoreLocationInfo({
    required this.storeCode,
    required this.storeName,
    required this.address,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory StoreLocationInfo.fromJson(Map<String, dynamic> json) {
    return StoreLocationInfo(
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      address: json['address'],
      distance: json['distance'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

final storeInfoListNotifierProvider =
    StateNotifierProvider<StoreInfoListNotifier, List<StoreLocationInfo>>(
        (ref) {
  return StoreInfoListNotifier([]);
});

class StoreInfoListNotifier extends StateNotifier<List<StoreLocationInfo>> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가

  StoreInfoListNotifier(List<StoreLocationInfo> initialState)
      : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreInfoList : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    subscribeToNearestStores(); // 구독 시작
  }

  // 가게 정보를 구독하는 메소드
  void subscribeToNearestStores() {
    _client?.subscribe(
      destination: '/topic/user/storeList/nearestStores',
      callback: (frame) {
        if (frame.body != null) {
          print("subscribeToNearestStores : ${frame.body}");
          List<dynamic> result = json.decode(frame.body!);
          List<StoreLocationInfo> newList =
              result.map((item) => StoreLocationInfo.fromJson(item)).toList();
          state = newList; // 상태 업데이트
        }
      },
    );
    print("StoreInfoList : subscribe!");
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendMyLocation(double latitude, double longitude) {
    _client?.send(
      destination: '/app/user/storeList/nearestStores',
      body: json.encode({"latitude": latitude, "longitude": longitude}),
    );
  }

  void unSubscribe() {
    dynamic unsubscribeFn = _client?.subscribe(
        destination: '/topic/user/storeInfo',
        headers: {},
        callback: (frame) {
          // Received a frame for this subscription
          print(frame.body);
        });
    unsubscribeFn(unsubscribeHeaders: {});
  }

  @override
  void dispose() {
    unSubscribe();
    super.dispose();
  }
}
