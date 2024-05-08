import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orre/presenter/user/onboarding_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';

class SettingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('테마 설정'),
            onTap: () {},
          ),
          ListTile(
            title: Text('알림 설정'),
            onTap: () {},
          ),
          ListTile(
            title: Text('로그아웃'),
            onTap: () {
              ref.read(userInfoProvider.notifier).clearUserInfo();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OnboardingScreen()),
              );
            },
          ),
          ListTile(
            title: Text('회원탈퇴'),
            onTap: () {
              ref.read(userInfoProvider.notifier).withdraw().then((value) {
                print("회원탈퇴 결과: $value");
                if (value) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
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
    );
  }
}
