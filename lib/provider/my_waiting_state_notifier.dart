import 'package:flutter_riverpod/flutter_riverpod.dart';

// App State로 사용할 "나의 대기정보"의 구성 멤버를 정의해준다
class MyWaitingInfo {
  final String storeCode;
  final int waitingNumber;

  final String myName;
  final String phoneNumber;
  final int numberOfUs;

  MyWaitingInfo({
    required this.storeCode,
    required this.waitingNumber,
    required this.myName,
    required this.phoneNumber,
    required this.numberOfUs,
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
            myName: info.myName,
            phoneNumber: info.phoneNumber,
            numberOfUs: newNumberOfUs,
          )
        else
          // 해당 가게가 아닐 시 원래 state 정보를 사용
          info,
    ];
  }
}

// 이제 myWaitingsProvider 통해 MyWaitingInfo모델의 리스트를 관리할 수 있음
final myWaitingsProvider =
    StateNotifierProvider<MyWaitingStateNotifier, List<MyWaitingInfo>>((ref) {
  return MyWaitingStateNotifier();
});
