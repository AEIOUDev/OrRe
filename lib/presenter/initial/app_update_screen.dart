import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../provider/app_state_provider.dart';
import '../../services/debug.services.dart';

class AppUpdateScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자의 데이터를 가져오거나 로직을 적용할 곳입니다.
    printd("\n\n AppUpdateScreen 진입");
    final appInfo = ref.watch(appVersionProvider);
    final latestAppInfo = ref.watch(latestAppVersionProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white, // 배경색을 주어진 이미지 색상과 유사하게 설정합니다.
      body: WaveformBackgroundWidget(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0.25.sh),
            ClipOval(
              child: Container(
                color: Color(0xFFFFFFBF52),
                child: Image.asset(
                  "assets/images/orre_logo.png",
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  height: MediaQuery.sizeOf(context).width * 0.5,
                ),
              ),
            ),
            SizedBox(
              height: 32.h,
            ),
            TextWidget(
              '앱의 업데이트가 필요합니다.',
              fontFamily: 'Dovemayo_gothic',
              fontSize: 24,
              color: Color(0xFFFFFFBF52),
            ),
            SizedBox(
              height: 16.h,
            ),
            TextWidget("현재 버전 : ${appInfo}"),
            SizedBox(
              height: 16.h,
            ),
            TextWidget("최신 버전 : ${latestAppInfo}"),
            Spacer(),
            // 버튼들을 추가합니다.
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 32.0),
            //   child: BigButtonWidget(
            //     onPressed: () {
            //       // 로그인 로직을 추가합니다.
            //       context.push('/user/signin');
            //     },
            //     backgroundColor: Color(0xFFFFFFBF52), // 버튼 배경색을 조절합니다.
            //     minimumSize: Size(double.infinity, 50), // 버튼 크기를 조절합니다.
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(15.0),
            //     ),
            //     text: '로그인',
            //     textColor: Colors.white,
            //   ),
            // ),
            Spacer(flex: 2),

            // 버튼을 추가합니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: BigButtonWidget(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
                backgroundColor: Color(0xFFFFFFBF52), // 버튼 배경색을 조절합니다.
                minimumSize: Size(double.infinity, 50), // 버튼 크기를 조절합니다.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                text: '앱 종료',
                textColor: Colors.white,
              ),
            ),

            Spacer(
              flex: 4,
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 20,
                color: Color(0xFFFFBF52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
