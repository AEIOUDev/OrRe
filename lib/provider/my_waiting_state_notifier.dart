import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 요청자의 정보를 담는 모델
class MyInfo {
  final String myName;
  final String phoneNumber;
  final int numberOfUs;

  MyInfo({
    required this.myName,
    required this.phoneNumber,
    required this.numberOfUs,
  });
}

// App State로 사용할 "나의 대기정보"의 구성 멤버를 정의해준다
class MyWaitingInfo {
  final String storeCode;
  final int waitingNumber;

  final MyInfo myInfo;

  MyWaitingInfo({
    required this.storeCode,
    required this.waitingNumber,
    required this.myInfo,
  });
}

// List 형식으로 관리하려고 함. 따라서 List<MyWaitingInfo> 형식으로 선언
class MyWaitingStateNotifier extends StateNotifier<List<MyWaitingInfo>> {
  // StateNotifier를 빈 배열로 초기화
  MyWaitingStateNotifier() : super([]);

  // 사용자가 웨이팅을 추가함
  void addWaiting(MyWaitingInfo newWaiting) {
    state = [...state, newWaiting];
  }

  // 사용자가 웨이팅을 제거함
  void removeWaiting(MyWaitingInfo removeWaiting) {
    state = state.where((waiting) => waiting != removeWaiting).toList();
  }

  // 특정 MyWaitingInfo의 numberOfUs를 업데이트
  void updateNumberOfUs(String storeCode, int newNumberOfUs) {
    state = [
      for (final info in state)
        // 한 가게에서 웨이팅을 한 번만 진행할 수 있기 때문에, 웨이팅 번호는 조건에 관여하지 않음
        if (info.storeCode == storeCode)
          // 기존 웨이팅 정보에서, 해당 가게의 인원 수만 변경하여 새로운 웨이팅 리스트 생성
          MyWaitingInfo(
            storeCode: info.storeCode,
            waitingNumber: info.waitingNumber,
            myInfo: MyInfo(
                myName: info.myInfo.myName,
                phoneNumber: info.myInfo.phoneNumber,
                numberOfUs: newNumberOfUs),
          )
        else
          // 해당 가게가 아닐 시 원래 state 정보를 사용
          info,
    ];
  }

  void requestWaiting(String storeCode, MyInfo myInfo) {
    // 서버와의 웹소켓 통신을 모의하는 로직
    // 실제 애플리케이션에서는 여기서 웹소켓 통신 코드를 작성하여 서버에 웨이팅 합류 요청을 보내야 함

    // 예제를 위한 가상의 응답 처리
    Timer(Duration(seconds: 1), () {
      // 웨이팅에 성공적으로 합류했다고 가정
      final bool success = true; // 실제 서버 응답을 기반으로 설정
      if (success) {
        final int newWaitingNumber = state.length + 1; // 서버에서 받은 웨이팅 번호를 사용해야 함
        addWaiting(MyWaitingInfo(
          storeCode: storeCode,
          waitingNumber: newWaitingNumber,
          myInfo: myInfo,
        ));

        // UI에 성공 메시지 또는 웨이팅 정보 업데이트를 알리는 로직 구현 필요
      } else {
        // 합류 실패 시 에러 처리 로직 구현 필요
      }
    });
  }
}

// 이제 myWaitingsProvider 통해 MyWaitingInfo모델의 리스트를 관리할 수 있음
final myWaitingsProvider =
    StateNotifierProvider<MyWaitingStateNotifier, List<MyWaitingInfo>>((ref) {
  return MyWaitingStateNotifier();
});
