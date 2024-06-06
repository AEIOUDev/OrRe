import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug.services.dart';

class OnboardingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자의 데이터를 가져오거나 로직을 적용할 곳입니다.
    printd("\n\n OnboardingScreen 진입");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white, // 배경색을 주어진 이미지 색상과 유사하게 설정합니다.
      body: WaveformBackgroundWidget(
        backgroundColor: Colors.white,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 0.25.sh),
                TextWidget(
                  '오리',
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 32.sp,
                  color: Colors.black,
                  letterSpacing: 40.sp,
                ),
                SizedBox(
                  height: 20.h,
                ),
                ClipOval(
                  child: Container(
                    color: Color(0xFFFFFFBF52),
                    child: Image.asset(
                      "assets/images/orre_logo.png",
                      width: 200.h,
                      height: 200.h,
                    ),
                  ),
                ),
                TextWidget(
                  '원격 줄서기 원격 주문 서비스',
                  fontFamily: 'Dovemayo_gothic',
                  fontSize: 16.sp,
                  color: Color(0xFFFFFFBF52),
                ),
                Spacer(),
                // 버튼들을 추가합니다.
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 8.0.h),
                  child: BigButtonWidget(
                    onPressed: () {
                      // 로그인 로직을 추가합니다.
                      context.push('/user/signin');
                    },
                    backgroundColor: Color(0xFFFFFFBF52), // 버튼 배경색을 조절합니다.
                    minimumSize: Size(double.infinity, 50.h), // 버튼 크기를 조절합니다.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    text: '로그인',
                    textColor: Colors.white,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 8.0.h),
                  child: BigButtonWidget(
                    onPressed: () {
                      // 회원 가입 로직을 추가합니다.
                      context.push('/user/agreement');
                    },
                    backgroundColor: Color(0xFFDFDFDF), // 버튼 배경색을 조절합니다.
                    minimumSize: Size(double.infinity, 50.h), // 버튼 크기를 조절합니다.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    text: '회원 가입',
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 20.h,
                color: Color(0xFFFFBF52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
