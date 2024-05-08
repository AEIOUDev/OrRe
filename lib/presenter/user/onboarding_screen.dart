import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/user/sign_in_screen.dart';
import 'package:orre/presenter/user/sign_up_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자의 데이터를 가져오거나 로직을 적용할 곳입니다.

    return Scaffold(
      backgroundColor: Color(0xFFFFE0B2), // 배경색을 주어진 이미지 색상과 유사하게 설정합니다.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100, // 앱바의 높이를 조절합니다.
        // 이 부분에 로고나 아이콘을 추가할 수 있습니다.
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(),
            // 로고 위젯을 추가합니다. 이미지나 커스텀 위젯을 사용할 수 있습니다.
            // 예시로 Text 위젯을 사용했습니다.
            Text(
              '오 리',
              style: TextStyle(
                fontSize: 48, // 글자 크기를 조절합니다.
                fontWeight: FontWeight.bold, // 글자 두께를 조절합니다.
              ),
            ),
            ClipOval(
              child: Container(
                color: Colors.orange,
                child: Image.asset(
                  "assets/images/orre_logo.png",
                  width: 250,
                  height: 250,
                ),
              ),
            ),
            Text(
              '원격 줄서기 원격 주문 서비스',
              style: TextStyle(
                fontSize: 16, // 글자 크기를 조절합니다.
              ),
            ),
            Spacer(),
            // 버튼들을 추가합니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  // 로그인 로직을 추가합니다.
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFB74D), // 버튼 배경색을 조절합니다.
                  minimumSize: Size(double.infinity, 50), // 버튼 크기를 조절합니다.
                ),
                child: Text('로그인'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: OutlinedButton(
                onPressed: () {
                  // 회원 가입 로직을 추가합니다.
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black), // 테두리 색을 조절합니다.
                  minimumSize: Size(double.infinity, 50), // 버튼 크기를 조절합니다.
                ),
                child: Text('회원 가입'),
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
