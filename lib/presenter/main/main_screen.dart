import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:orre/presenter/homescreen/home_screen.dart';
import 'package:orre/provider/location/location_securestorage_provider.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/network/https/get_service_log_state_notifier.dart';
import 'package:orre/provider/network/https/store_list_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/services/debug.services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/location_model.dart';
import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../services/nfc_services.dart';
import '../../widget/popup/awesome_dialog_widget.dart';
import '../order/order_prepare_screen.dart';
import '../waiting/waiting_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';

final selectedIndexProvider = StateProvider<int>((ref) {
  return 1; // 기본적으로 '홈'을 선택 상태로 시작합니다.
});

final appLifeCycleStateProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

enum pageIndex {
  orderScreen,
  homeScreen,
  waitingScreen;
}

class MainScreen extends ConsumerStatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    // _initialize();
  }

  // Future<void> _initialize() async {
  //   printd("MainScreen 초기화 시작");
  //   await refresh();
  //   printd("MainScreen 초기화 완료");
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // 앱의 상태 변화에 따른 작업
    switch (state) {
      case AppLifecycleState.resumed:
        printd("앱이 다시 활성화될 때");
        printd("provider isPaused? : ${ref.read(appLifeCycleStateProvider)}");
        printd("state isPaused? : ${state}");
        printd("isSame : ${ref.read(appLifeCycleStateProvider) == state}");
        if (ref.read(appLifeCycleStateProvider) == state) {
          printd("앱이 백그라운드에서 복귀했을 때");
          ref.read(appLifeCycleStateProvider.notifier).state =
              AppLifecycleState.resumed;
          return;
        }
        ref.read(appLifeCycleStateProvider.notifier).state =
            AppLifecycleState.resumed; // 앱이 다시 활성화될 때
        // 앱이 다시 활성화될 때
        final userInfo = ref.read(userInfoProvider);
        final stomp = ref.read(stompClientStateNotifierProvider);
        printd("stomp : " + stomp.toString());
        printd("stomp.connected : " +
            (stomp?.connected.toString() ?? "stomp is null"));
        printd("stomp.active : " +
            (stomp?.isActive.toString() ?? "stomp is null"));
        if (userInfo != null) {
          printd("사용자 정보가 있습니다.");
          if (stomp != null && stomp.connected) {
            printd("Stomp 연결이 되어 있습니다.");
            await refresh();
          } else {
            printd("Stomp 연결이 되어 있지 않습니다.");
            await refresh();
          }
        } else {
          printd("사용자 정보가 없습니다.");
          context.go('/user/onboarding');
        }
        break;
      case AppLifecycleState.inactive:
        // 앱이 비활성화될 때
        printd("앱이 비활성화될 때");
        break;
      case AppLifecycleState.paused:
        // 앱이 일시 중지될 때
        printd("앱이 일시 중지될 때");
        // ref
        //     .read(storeWaitingInfoNotifierProvider.notifier)
        //     .clearWaitingInfoList();
        ref.read(storeListProvider.notifier).clearRequest();
        ref.read(appLifeCycleStateProvider.notifier).state =
            AppLifecycleState.paused;
        break;
      case AppLifecycleState.detached:
        // 앱이 종료될 때
        printd("앱이 종료될 때");
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        printd("앱이 숨겨질 때");
        break;
    }
  }

  Future<void> refresh() async {
    printd("refresh 함수 시작");
    context.loaderOverlay.show();

    await ref.read(stompClientStateNotifierProvider.notifier).reactive();

    final userSelectedLocation =
        ref.read(locationListProvider).selectedLocation;
    final userNowLocation = ref.read(locationListProvider).nowLocation;

    // 사용자가 선택한 위치와 현재 위치가 같았을 경우 현재 위치를 업데이트 하고 SelectedLocation도 동일한 값으로 업데이트
    if (userSelectedLocation == userNowLocation) {
      printd("사용자가 선택한 위치와 현재 위치가 동일함. 현재 위치 업데이트 및 선택 위치 동기화");
      await ref.read(nowLocationProvider.notifier).updateNowLocation();
      ref.read(locationListProvider.notifier).selectLocationToNowLocation();
    } else {
      // 현재 위치만 업데이트 하고, 이전 selectedLocation은 그대로
      printd("사용자가 선택한 위치와 현재 위치가 다름. 현재 위치만 업데이트");

      // 이 때 사용자가 선택한 위치가 "현재 위치"로 설정되어 있을 경우, 현재 위치를 업데이트합니다.
      await ref.read(nowLocationProvider.notifier).updateNowLocation();
      if (userNowLocation?.locationName == "현재 위치") {
        printd("사용자가 선택한 위치가 현재 위치로 설정되어 있음. 현재 위치 업데이트");
        ref.read(locationListProvider.notifier).selectLocationToNowLocation();
      } else {
        printd("사용자가 선택한 위치가 현재 위치로 설정되어 있지 않음. 현재 위치 업데이트 안함");
      }
    }

    // selectedLocation으로 가게 정보를 다시 불러옵니다.
    final userLocation = ref.read(locationListProvider).selectedLocation;
    printd("선택된 위치 : " + (userLocation?.locationName ?? "null"));

    if (userLocation != null) {
      printd("선택된 위치로 가게 정보 불러오기 시작");
      await ref.read(storeListProvider.notifier).fetchStoreDetailInfo(
          StoreListParameters(
              sortType: ref.watch(selectSortTypeProvider),
              latitude: userLocation.latitude,
              longitude: userLocation.longitude));
    } else {
      // 사용자가 위치를 선택하지 않았을 경우엔 기본값으로 현재 위치를 사용합니다.
      printd("사용자가 위치를 선택하지 않음. 기본값으로 현재 위치 사용");
      final location = LocationInfo.nullValue();
      await ref.read(storeListProvider.notifier).fetchStoreDetailInfo(
          StoreListParameters(
              sortType: ref.watch(selectSortTypeProvider),
              latitude: location.latitude,
              longitude: location.longitude));
    }

    // 해당 가게 정보로 대기 정보를 다시 불러옵니다.
    final storeList = ref.read(storeListProvider);
    if (storeList.isNotEmpty) {
      printd("가게 정보 있음. 기존 대기정보 삭제하고, 가게별 대기 정보 다시 불러오기 시작");
      ref
          .read(storeWaitingInfoNotifierProvider.notifier)
          .clearWaitingInfoList();
      storeList.forEach((element) {
        // 가게별 대기 정보를 불러옵니다.
        ref
            .read(storeWaitingInfoNotifierProvider.notifier)
            .subscribeToStoreWaitingInfo(element.storeCode);
      });
    } else {
      // 가게 정보가 없을 경우 대기 정보도 초기화합니다.
      printd("가게 정보 없음. 대기 정보 초기화");
      ref
          .read(storeWaitingInfoNotifierProvider.notifier)
          .clearWaitingInfoList();
    }

    // 사용자 정보가 있을 경우 서비스 로그를 다시 불러옵니다.
    final userInfo = ref.read(userInfoProvider);
    if (userInfo != null) {
      printd("사용자 정보 있음. 서비스 로그 불러오기 시작");
      ServiceLogResponse serviceLog = await ref
          .refresh(serviceLogProvider.notifier)
          .fetchStoreServiceLog(userInfo.phoneNumber);

      printd("서비스 로그 불러오기 완료");

      // 서비스 로그를 불러온 후, 재구독 로직 실행
      if (serviceLog.userLogs.isNotEmpty) {
        printd("서비스 로그 있음. 웹소켓 재연결");
        ref
            .read(serviceLogProvider.notifier)
            .reconnectWebsocketProvider(serviceLog.userLogs.last);
      } else {
        printd("서비스 로그 없음. 웹소켓 재구독 안함");
      }
    } else {
      // 사용자 정보가 없을 경우 로그인 페이지로 이동합니다.
      printd("사용자 정보 없음. 로그인 페이지로 이동");
      context.go('/user/onboarding');
    }

    printd("refresh 함수 종료");
    context.loaderOverlay.hide();
    return;
  }

  @override
  Widget build(BuildContext context) {
    printd("\n\nMainScreen build 진입");

    final selectedIndex = ref.watch(selectedIndexProvider);

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
          selectedItemColor: Color(0xFFFFFFBF52),
          unselectedItemColor: Color(0xFFDFDFDF),
          currentIndex: selectedIndex, // 현재 선택된 인덱스
          onTap: (index) {
            // 사용자가 탭을 선택할 때 상태 업데이트
            ref.read(selectedIndexProvider.notifier).state = index;
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        //Init Floating Action Bubble
        floatingActionButton: FloatingActionBubble(
          // Menu items
          items: <Bubble>[
            // Floating action menu item
            if (Platform.isIOS && ref.read(nfcAvailableProvider))
              Bubble(
                title: "NFC 스캔",
                iconColor: Colors.white,
                bubbleColor: Color(0xFFFFBF52),
                icon: Icons.phonelink_ring_rounded,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  startNFCScan(ref, context);
                  _animationController.reverse();
                },
              ),
            //Floating action menu item
            Bubble(
              title: "QR 스캔",
              iconColor: Colors.white,
              bubbleColor: Color(0xFFFFBF52),
              icon: Icons.qr_code_scanner_rounded,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                Permission.camera.request().then((value) {
                  if (value.isGranted) {
                    context.push('/main/qrscanner');
                  } else {
                    // 카메라 권한이 없을 경우, 권한 요청
                    AwesomeDialogWidget.showCustomDialogWithCancel(
                      context: context,
                      title: "카메라 권한",
                      desc: "카메라 권한이 없습니다. 설정으로 이동하여 권한을 허용해주세요.",
                      dialogType: DialogType.warning,
                      onPressed: () {
                        openAppSettings();
                      },
                      btnText: "설정으로 이동",
                      onCancel: () {
                        context.go("/main");
                      },
                      cancelText: "취소",
                    );
                  }
                  _animationController.reverse();
                });
              },
            ),
          ],

          // animation controller
          animation: _animation,

          // On pressed change animation state
          onPress: () => _animationController.isCompleted
              ? _animationController.reverse()
              : _animationController.forward(),

          // Floating Action button Icon color
          iconColor: Colors.white,

          // Flaoting Action button Icon
          iconData: Icons.menu,
          backGroundColor: Color(0xFFFFBF52),
        ));
  }
}
