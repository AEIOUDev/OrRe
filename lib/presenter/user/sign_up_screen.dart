import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/user/phone_number_authentication.dart';

class SignUpUserInfo {
  PhoneNumberAuthenticationInfo authInfo;
  String nickname;
  String password;

  SignUpUserInfo(
      {required this.authInfo, required this.nickname, required this.password});
}

class SingUpScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(
          '회원 가입',
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.right,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        leadingWidth: 100,
      ),
      backgroundColor: Color(0xFFFFE0B2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 여기에 TextField들을 배치합니다.
              Row(children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                      context, '닉네임을 입력해주세요.', false, TextInputType.text, ref),
                ),
              ]),
              SizedBox(height: 16),
              Row(children: [
                Icon(Icons.lock),
                SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(context, '비밀번호를 입력해주세요.', true,
                      TextInputType.visiblePassword, ref),
                ),
              ]),
              SizedBox(height: 16),
              PhoneNumberAuthenticationPresenter(),
              SizedBox(height: 32),
              // 하단 "회원 가입하기" 버튼
              ElevatedButton(
                onPressed: () {
                  // 여기에 회원가입 로직을 추가합니다.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFB74D),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  '회원 가입하기',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hintText, bool isPassword,
      TextInputType type, WidgetRef ref) {
    return TextField(
      autofillHints: type == TextInputType.text
          ? [AutofillHints.name]
          : (type == TextInputType.visiblePassword
              ? [AutofillHints.password]
              : null),
      keyboardType: type,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
