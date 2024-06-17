import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../provider/network/https/post_school_meal_future_provider.dart';
import '../../services/debug_services.dart';
import '../../services/hardware/haptic_services.dart';
import '../../services/notifications_services.dart';
import '../../widget/button/small_button_widget.dart';
import '../../widget/loading_indicator/coustom_loading_indicator.dart';
import '../../widget/popup/awesome_dialog_widget.dart';
import '../../widget/text/text_widget.dart';

class ConvenienceScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFDFDFDF),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: TextWidget(
          '편의기능',
          fontSize: 20.sp,
          color: Colors.black,
        ),
        centerTitle: false,
        backgroundColor: Color(0xFFFFB74D),
        toolbarHeight: 58.h,
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.black,
              size: 20.sp,
            ),
            onPressed: () async {
              await HapticServices.vibrate(ref, CustomHapticsType.selection);
              printd("즐겨찾기 페이지로 이동이지만 지금은 이스터에그");
              // 즐겨찾기 페이지로 이동
              final status = await Permission.notification.status;
              if (status.isDenied || status.isPermanentlyDenied) {
                AwesomeDialogWidget.showCustomDialogWithCancel(
                  context: context,
                  title: "위치 권한 없음!",
                  desc: "웨이팅 알림을 받으려면 알림 권한이 필요합니다.",
                  dialogType: DialogType.warning,
                  onPressed: () async {
                    openAppSettings();
                  },
                  btnText: "설정으로 이동",
                  onCancel: () {},
                  cancelText: "나중에",
                );
              } else {
                NotificationService.showNotification(
                    NotificationType.easteregg);
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
              size: 20.sp,
            ),
            onPressed: () async {
              await HapticServices.vibrate(ref, CustomHapticsType.selection);
              // 설정 페이지로 이동
              context.push("/setting");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              // 3개의 동일한 border radius가 적용된 Column
              // 학식
              children: [
                BorderContainer(
                  child: SchoolMealItem(
                    location: "혜당관",
                  ),
                ),

                // 메뉴 추천
                BorderContainer(
                  child: MenuRecommendItem(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SchoolMealItem extends ConsumerWidget {
  final String location;

  SchoolMealItem({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureProvider = ref.watch(schoolMealFutureProvider(location));

    return futureProvider.when(
      data: (schoolMeal) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextWidget(
                  "오늘의 학식 (${schoolMeal.restaurantLocation})",
                  fontSize: 24.sp,
                  color: Color(0xFFFFB74D),
                ),
                Spacer(),
                TextWidget(
                  schoolMeal.date,
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextWidget(
              schoolMeal.breakfast,
              maxLines: 10,
              textAlign: TextAlign.left,
              fontSize: 16.sp,
              color: Colors.black,
            ),
            SizedBox(height: 8.h),
            TextWidget(
              schoolMeal.lunch,
              maxLines: 10,
              textAlign: TextAlign.left,
              fontSize: 16.sp,
              color: Colors.black,
            ),
            SizedBox(height: 8.h),
            TextWidget(
              schoolMeal.dinner,
              maxLines: 10,
              textAlign: TextAlign.left,
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ],
        );
      },
      loading: () => CustomLoadingIndicator(),
      error: (error, stack) {
        return SmallButtonWidget(
          text: "새로고침",
          onPressed: () {
            ref.invalidate(schoolMealFutureProvider(location));
          },
        );
      },
    );
  }
}

class MenuRecommendItem extends ConsumerStatefulWidget {
  @override
  _MenuRecommendItemState createState() => _MenuRecommendItemState();
}

class _MenuRecommendItemState extends ConsumerState<MenuRecommendItem> {
  late StreamController<int> controller;
  final List<String> menuList = [
    "비빔밥",
    "불고기",
    "갈비",
    "삼겹살",
    "된장찌개",
    "김치찌개",
    "순두부찌개",
    "부대찌개",
    "햄버거",
    "육개장",
    "설렁탕",
    "감자탕",
    "닭갈비",
    "족발",
    "보쌈",
    "해물파전",
    "잡채",
    "갈비찜",
    "오리불고기",
    "해물탕",
    "갈비탕",
    "매운탕",
    "닭볶음탕",
    "콩나물국밥",
    "해장국",
    "비빔국수",
    "칼국수",
    "잔치국수",
    "쌀국수",
    "냉면",
    "순대국",
    "곰탕",
    "부대찌개",
    "아구찜",
    "황태해장국",
    "오징어볶음",
    "제육볶음",
    "닭강정",
    "감자전",
    "장어구이",
    "꼬막비빔밥",
    "추어탕",
    "삼계탕",
    "닭백숙",
    "낙곱새",
    "문어숙회",
    "육회비빔밥",
    "연어덮밥",
    "낙지볶음",
    "고등어조림",
    "참치김밥",
    "돌솥비빔밥",
    "고추장찌개",
    "김치볶음밥",
    "짜장면",
    "짬뽕",
    "탕수육",
    "깐풍기",
    "깐쇼새우",
    "사천짜장",
    "불닭볶음면",
    "라볶이",
    "쭈꾸미볶음",
    "해물찜",
    "조개찜",
    "한식뷔페",
    "샤브샤브",
    "고기전골",
    "불낙전골",
    "매운갈비찜",
    "뼈해장국",
    "홍합탕",
    "모듬회",
    "광어회",
    "연어회",
    "회덮밥",
    "초밥",
    "생선초밥",
    "유부초밥",
    "날치알주먹밥",
    "유린기",
    "마파두부",
    "짬뽕밥",
    "차돌된장찌개",
    "스테이크덮밥",
    "치킨가라아게",
    "카레라이스",
    "치즈돈까스",
    "닭꼬치",
    "돈부리",
    "알밥",
    "산낙지",
    "수육",
    "도미조림",
    "된장국",
    "보리밥",
    "고추튀김",
    "순살치킨",
    "떡갈비",
    "고추장불고기",
    "순두부찌개",
    "김치찜",
  ];

  @override
  void initState() {
    controller = StreamController<int>();
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            TextWidget(
              "메뉴 추천",
              fontSize: 24.sp,
              color: Color(0xFFFFB74D),
            ),
            Spacer(),
            TextWidget(
              "뭘 먹어야 잘 먹었다고 소문이 날까?",
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Consumer(
          builder: (context, ref, child) {
            return Flexible(
              child: Container(
                child: FortuneBar(
                  // changing the return animation when the user stops dragging
                  duration: Duration(seconds: 2),
                  // styleStrategy: AlternatingStyleStrategy(),
                  animateFirst: false,
                  selected: controller.stream,
                  indicators: [
                    FortuneIndicator(
                      child: RectangleIndicator(
                        color: Colors.transparent,
                        borderColor: Color(0xFFFFB74D),
                        borderWidth: 2,
                      ),
                    ),
                  ],
                  curve: Curves.easeInOutCubicEmphasized,
                  items: [
                    for (var i = 0; i < menuList.length; i++)
                      FortuneItem(
                        child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: TextWidget(
                            menuList[i],
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                  onAnimationEnd: () async {
                    await HapticServices.vibrate(
                        ref, CustomHapticsType.success);
                  },
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        SmallButtonWidget(
          text: "추천해줘!",
          minSize: Size(75.w, 45.h),
          maxSize: Size(155.w, 60.h),
          onPressed: () async {
            await HapticServices.vibrate(ref, CustomHapticsType.selection);
            controller.add(Random().nextInt(menuList.length));
          },
        ),
      ],
    );
  }
}

class BorderContainer extends ConsumerWidget {
  final Widget child;

  BorderContainer({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.fromLTRB(8.w, 16.h, 8.h, 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
