import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/location_model.dart';
import '../model/menu_info_model.dart';
import '../model/store_info_model.dart';
import '../model/user_info_model.dart';

// List 형식으로 관리하려고 함. 따라서 List<UserWaitingStoreInfo> 형식으로 선언
class MyWaitingStateNotifier extends StateNotifier<List<UserWaitingStoreInfo>> {
  // StateNotifier를 빈 배열로 초기화
  MyWaitingStateNotifier() : super([]);

  // 사용자가 웨이팅을 추가함
  void addWaiting(UserWaitingStoreInfo newWaiting) {
    state = [...state, newWaiting];
  }

  // 사용자가 웨이팅을 제거함
  void removeWaiting(UserWaitingStoreInfo removeWaiting) {
    state = state.where((waiting) => waiting != removeWaiting).toList();
  }

  // 특정 UserWaitingStoreInfo의 numberOfUs를 업데이트
  void updateNumberOfUs(String storeCode, int newNumberOfUs) {
    state = [
      for (final info in state)
        // 한 가게에서 웨이팅을 한 번만 진행할 수 있기 때문에, 웨이팅 번호는 조건에 관여하지 않음
        if (info.storeInfo.storeCode == storeCode)
          // 기존 웨이팅 정보에서, 해당 가게의 인원 수만 변경하여 새로운 웨이팅 리스트 생성
          UserWaitingStoreInfo(
            storeInfo: info.storeInfo,
            waitingNumber: info.waitingNumber,
            userSimpleInfo: UserSimpleInfo(
                name: info.userSimpleInfo.name,
                phoneNumber: info.userSimpleInfo.phoneNumber,
                numberOfUs: newNumberOfUs),
          )
        else
          // 해당 가게가 아닐 시 원래 state 정보를 사용
          info,
    ];
  }

  void requestWaiting(String storeCode, UserSimpleInfo userSimpleInfo) {
    // 서버와의 웹소켓 통신을 모의하는 로직
    // 실제 애플리케이션에서는 여기서 웹소켓 통신 코드를 작성하여 서버에 웨이팅 합류 요청을 보내야 함

    // 예제를 위한 가상의 응답 처리
    Timer(Duration(seconds: 1), () {
      // 웨이팅에 성공적으로 합류했다고 가정
      final bool success = true; // 실제 서버 응답을 기반으로 설정
      final storeInfo = StoreInfo(
        storeCode: storeCode,
        storeName: "포멜로",
        storeInfoVersion: 1,
        locationInfo: LocationInfo(
            address: "경기도 용인시 보정동 1189-3",
            latitude: 37.34420805351488,
            locationName: "보정동 포멜로",
            longitude: 127.1187733611165),
        menuList: [
          MenuInfo(
              menuCode: "A01",
              menuName: "라면",
              menuDescription: "매콤짭짤",
              menuPrice: 2000,
              menuImage: Image.asset("test"),
              isRecommended: true)
        ],
      );
      if (success) {
        final int newWaitingNumber = state.length + 1; // 서버에서 받은 웨이팅 번호를 사용해야 함
        addWaiting(UserWaitingStoreInfo(
          storeInfo: storeInfo,
          waitingNumber: newWaitingNumber,
          userSimpleInfo: userSimpleInfo,
        ));

        // UI에 성공 메시지 또는 웨이팅 정보 업데이트를 알리는 로직 구현 필요
      } else {
        // 합류 실패 시 에러 처리 로직 구현 필요
      }
    });
  }
}

// 이제 myWaitingsProvider 통해 UserWaitingStoreInfo모델의 리스트를 관리할 수 있음
final myWaitingsProvider =
    StateNotifierProvider<MyWaitingStateNotifier, List<UserWaitingStoreInfo>>(
        (ref) {
  return MyWaitingStateNotifier();
});
