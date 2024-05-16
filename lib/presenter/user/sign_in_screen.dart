import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/main.dart';
import 'package:orre/presenter/user/sign_up_reset_password_screen.dart';
import 'package:orre/presenter/user/sign_up_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';

import 'package:orre/widget/text_field/text_input_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';

import 'package:orre/model/user_info_model.dart';

final isObscureProvider = StateProvider<bool>((ref) => true);
final formKeyProvider = Provider((ref) => GlobalKey<FormState>());

class SignInScreen extends ConsumerWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscure = ref.watch(isObscureProvider);
    final formKey = ref.watch(formKeyProvider);

    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.25),
          child: StaticAppBarWidget(
              title: '로그인',
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 16 * 5),
                    // 전화번호 입력창
                    TextInputWidget(
                      prefixIcon: Icon(Icons.phone),
                      hintText: '전화번호를 입력해주세요.',
                      isObscure: false,
                      type: TextInputType.number,
                      ref: ref,
                      autofillHints: [AutofillHints.telephoneNumber],
                      controller: phoneNumberController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      minLength: 11,
                      maxLength: 11,

                      focusNode: phoneNumberFocusNode, // Passing FocusNode
                    ),
                    SizedBox(height: 16),
                    // 비밀먼호 입력창
                    TextInputWidget(
                      hintText: '비밀번호를 입력해주세요.',
                      isObscure: isObscure,
                      type: TextInputType.emailAddress,
                      ref: ref,
                      controller: passwordController,
                      autofillHints: [AutofillHints.password],
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          ref.read(isObscureProvider.notifier).state =
                              !ref.watch(isObscureProvider.notifier).state;
                        },
                        icon: Icon((isObscure == false)
                            ? (Icons.visibility)
                            : (Icons.visibility_off)),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-zA-Z!@#$%^&*]'))
                      ],

                      focusNode: passwordFocusNode, // Passing FocusNode
                      minLength: 8,
                      maxLength: 20,
                    ),
                    SizedBox(height: 32),
                    // 하단 "회원 가입하기" 버튼
                    BigButtonWidget(
                        text: '로그인 하기',
                        textColor: Colors.white,
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final signInUserInfo = SignInInfo(
                            password: passwordController.text,
                            phoneNumber: phoneNumberController.text
                                .replaceAll(RegExp(r'[^0-9]'), ''),
                          );
                          print(signInUserInfo.password);
                          print(signInUserInfo.phoneNumber);
                          ref
                              .read(userInfoProvider.notifier)
                              .requestSignIn(signInUserInfo)
                              .then((value) async {
                            if (value != null) {
                              print("로그인 성공");
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              await Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return LocationStateCheckWidget();
                              }));
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertPopupWidget(
                                        title: '로그인 성공',
                                        subtitle: '$value님, 환영합니다!',
                                        buttonText: '확인');
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertPopupWidget(
                                        title: '로그인 실패',
                                        subtitle: '전화번호 또는 비밀번호를 확인해주세요.',
                                        buttonText: '확인');
                                  });
                            }
                          });
                        }),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 하단 "비밀번호 찾기" 버튼
                        TextButtonWidget(
                          text: '비밀번호 찾기',
                          fontSize: 16,
                          textColor: Color(0xFFDFDFDF),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SignUpResetPasswordScreen();
                            }));
                          },
                        ),
                        SizedBox(width: 10), // 여기서 간격을 조절해요
                        Container(
                          width: 1,
                          height: 18,
                          color: Color(0xFFDFDFDF),
                        ),
                        SizedBox(width: 10), // 여기서 간격을 조절해요
                        TextButtonWidget(
                          text: '회원가입',
                          fontSize: 16,
                          textColor: Color(0xFFFFBF52),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SignUpScreen();
                            }));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
