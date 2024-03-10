import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/home_screen.dart';

import '../services/nfc_services.dart';
import 'order/order_prepare_screen.dart';
import 'waiting/waiting_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) {
  return 1; // 기본적으로 '홈'을 선택 상태로 시작합니다.
});

enum pageIndex {
  orderScreen,
  homeScreen,
  waitingScreen;
}

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final nfcAvailable = ref.watch(nfcScanAvailableProvider);

    // 탭에 따라 표시될 페이지 리스트
    final pages = [
      OrderPrepareScreen(),
      HomeScreen(),
      WaitingScreen(), // 예시로 Text 위젯 사용, 실제로는 페이지 위젯을 사용합니다.
    ];

    return Scaffold(
      body: Center(
        child: pages[selectedIndex], // 선택된 인덱스에 따른 페이지 표시
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '주문',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '줄서기',
          ),
        ],
        currentIndex: selectedIndex, // 현재 선택된 인덱스
        onTap: (index) {
          // 사용자가 탭을 선택할 때 상태 업데이트
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (nfcAvailable) {
            startNFCScan(ref);
          } else {
            print(nfcAvailable);
          }
        },
        child: Icon(Icons.nfc),
        backgroundColor: (nfcAvailable
            ? Color.fromRGBO(255, 255, 255, 100)
            : Color.fromRGBO(0, 0, 0, 100)),
      ),
    );
  }
}
