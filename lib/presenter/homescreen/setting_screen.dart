import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../provider/app_state_provider.dart';

class SettingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(userInfoProvider.notifier).getNickname();

    return WaveformBackgroundWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.25.sh),
          child: StaticAppBarWidget(
            title: '설정',
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            '${nickname}님.',
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 36,
                          ),
                          TextWidget(
                            '만나서 반가워요 :)',
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 36,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      BigButtonWidget(
                        onPressed: () {
                          // 이용내역 확인 버튼 클릭 시 이용내역 확인 화면으로 이동
                          context.push("/setting/servicelog");
                        },
                        backgroundColor: Color(0xFFDFDFDF),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        text: '이용내역 확인',
                        textColor: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // BigButtonWidget(
                      //   onPressed: () {},
                      //   backgroundColor: Color(0xFFDFDFDF),
                      //   minimumSize: Size(double.infinity, 50),
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(15.0),
                      //   ),
                      //   text: '알림 설정',
                      //   textColor: Colors.black,
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      BigButtonWidget(
                        onPressed: () {
                          // 비밀번호 변경 버튼 클릭 시 비밀번호 변경 화면으로 이동
                          context.push('/user/resetpassword');
                        },
                        backgroundColor: Color(0xFFDFDFDF),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        text: '비밀번호 변경',
                        textColor: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButtonWidget(
                            text: '로그아웃',
                            fontSize: 16,
                            textColor: Color(0xFFDFDFDF),
                            onPressed: () {
                              AwesomeDialogWidget.showCustomDialogWithCancel(
                                context: context,
                                title: "로그아웃",
                                desc: "로그아웃 하시겠습니까?",
                                dialogType: DialogType.warning,
                                onPressed: () {
                                  print("로그아웃");

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    ref
                                        .read(userInfoProvider.notifier)
                                        .clearUserInfo();
                                    print(
                                        "로그아웃 후: ${ref.read(userInfoProvider)}");

                                    // 모든 화면을 pop한 후, OnboardingScreen으로 교체
                                    context.pop();
                                    context.go("/user/onboarding");
                                  });
                                },
                                btnText: "로그아웃",
                                onCancel: () {},
                                cancelText: "취소",
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 18,
                            color: Color(0xFFDFDFDF),
                          ),
                          SizedBox(width: 10),
                          TextButtonWidget(
                            text: '회원탈퇴',
                            fontSize: 16,
                            textColor: Color(0xFFDFDFDF),
                            onPressed: () {
                              AwesomeDialogWidget.showCustomDialogWithCancel(
                                  context: context,
                                  title: "회원탈퇴",
                                  desc: "정말 회원탈퇴 하시겠습니까?",
                                  dialogType: DialogType.warning,
                                  onPressed: () {
                                    ref
                                        .read(userInfoProvider.notifier)
                                        .withdraw()
                                        .then((value) async {
                                      print("회원탈퇴 결과: $value");
                                      if (value) {
                                        // 모든 화면을 pop한 후, OnboardingScreen으로 교체
                                        await ref
                                            .read(userInfoProvider.notifier)
                                            .clearAllInfo();
                                        context.pop();
                                        context.go("/user/onboarding");
                                      } else {
                                        // 회원탈퇴 실패
                                        AwesomeDialogWidget.showErrorDialog(
                                            context: context,
                                            title: "회원탈퇴",
                                            desc: "회원탈퇴에 실패했습니다.");
                                      }
                                    });
                                  },
                                  btnText: "탈퇴",
                                  onCancel: () {},
                                  cancelText: "취소");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40.h,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Consumer(builder: (context, ref, child) {
                  final appVersion = ref.watch(appVersionProvider);
                  return TextWidget(
                    "앱 버전 : $appVersion",
                    fontSize: 5.sp,
                    color: Colors.grey,
                  );
                }),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0.h,
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
