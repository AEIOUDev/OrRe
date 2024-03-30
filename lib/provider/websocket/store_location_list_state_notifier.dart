import 'dart:convert';

import 'package:orre/provider/home_screen/store_list_sort_type_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_screen/store_category_provider.dart';

class StoreLocationInfo {
  final String storeImageMain;
  final int storeCode;
  final String storeName;
  final String storeShortIntroduce;
  final String storeCategory;
  final String address;
  final double distance;
  final double latitude;
  final double longitude;

  StoreLocationInfo({
    required this.storeImageMain,
    required this.storeCode,
    required this.storeName,
    required this.storeShortIntroduce,
    required this.storeCategory,
    required this.address,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory StoreLocationInfo.fromJson(Map<String, dynamic> json) {
    return StoreLocationInfo(
      storeImageMain: json['storeImageMain'],
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeShortIntroduce: json['storeShortIntroduce'],
      storeCategory: json['storeCategory'],
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
  return StoreInfoListNotifier(ref, []);
});

class StoreInfoListNotifier extends StateNotifier<List<StoreLocationInfo>> {
  StompClient? _client; // StompClient 인스턴스를 저장할 내부 변수 추가
  late final Ref _ref; // Add a field to hold the Ref

  StoreInfoListNotifier(this._ref, List<StoreLocationInfo> initialState)
      : super(initialState);

  // StompClient 인스턴스를 설정하는 메소드
  void setClient(StompClient client) {
    print("StoreInfoList : setClient");
    _client = client; // 내부 변수에 StompClient 인스턴스 저장
    subscribeStoreList(); // 구독 시작
  }

  // 가게 정보를 구독하는 메소드
  void subscribeStoreList() {
    final sortType = _ref.read(selecteSortTypeProvider).toEn();
    _client?.subscribe(
      destination: '/topic/user/storeList/${sortType}',
      callback: (frame) {
        if (frame.body != null) {
          print("subscribeToNearestStores : ${frame.body}");
          List<dynamic> result = json.decode(frame.body!);
          // List<StoreLocationInfo> newList =
          //     result.map((item) => StoreLocationInfo.fromJson(item)).toList();
          // state = newList; // 상태 업데이트
          // 상태 업데이트 전에 선택된 카테고리에 따라 필터링

          categoryApply(result
              .map((item) => StoreLocationInfo.fromJson(item))
              .toList()); // 상태 업데이트 전에 선택된 카테고리에 따라 필터링
        }
      },
    );
    print("StoreInfoList : subscribe!");
  }

  void categoryApply(List<StoreLocationInfo> storeList) {
    // 선택된 카테고리 가져오기
    final selectedCategory = _ref.read(selecteCategoryProvider).toKoKr();
    // 모든 가게를 포함하거나 해당 카테고리와 일치하는 가게만 포함
    List<StoreLocationInfo> newList = storeList.where((store) {
      print("store.storeCategory : ${store.storeCategory}");
      return selectedCategory == '전체' ||
          store.storeCategory == selectedCategory;
    }).toList();
    state = newList; // 필터링된 리스트로 상태 업데이트
  }

  // 사용자의 위치 정보를 서버로 전송하는 메소드
  void sendMyLocation(double latitude, double longitude) {
    final sortType = _ref.read(selecteSortTypeProvider).toEn();
    _client?.send(
      destination: '/app/user/storeList/${sortType}',
      body: json.encode({"latitude": latitude, "longitude": longitude}),
    );
  }

  void unSubscribe() {
    final sortType = _ref.read(selecteSortTypeProvider).toEn();
    print("StoreInfoList : unSubscribe ${sortType}");
    dynamic unsubscribeFn = _client?.subscribe(
        destination: '/topic/user/storeInfo/${sortType}',
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
