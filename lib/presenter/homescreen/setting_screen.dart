import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/homescreen/service_log_screen.dart';

import 'package:orre/presenter/user/onboarding_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

class SettingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO : 엄마 닉네임 긁어와줘
    final nickname = '오리';

    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.25),
          child: StaticAppBarWidget(
            title: '설정',
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 100),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServiceLogScreen()));
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
                    BigButtonWidget(
                      onPressed: () {},
                      backgroundColor: Color(0xFFDFDFDF),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      text: '테마 설정',
                      textColor: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BigButtonWidget(
                      onPressed: () {},
                      backgroundColor: Color(0xFFDFDFDF),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      text: '알림 설정',
                      textColor: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BigButtonWidget(
                      onPressed: () {},
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
                    Center(
                      child: Row(
                        children: [
                          TextButtonWidget(
                            text: '로그아웃',
                            fontSize: 16,
                            textColor: Color(0xFFDFDFDF),
                            onPressed: () {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .clearUserInfo();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OnboardingScreen()),
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
                              ref
                                  .read(userInfoProvider.notifier)
                                  .withdraw()
                                  .then((value) {
                                print("회원탈퇴 결과: $value");
                                if (value) {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OnboardingScreen()),
                                  );
                                  AlertPopupWidget(
                                    title: '회원탈퇴',
                                    subtitle: '회원탈퇴가 완료되었습니다.',
                                    buttonText: '확인',
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
