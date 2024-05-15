import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/main_screen.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import 'package:orre/widget/popup/alert_popup_widget.dart';

import 'package:orre/widget/text_field/text_input_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';

import 'package:orre/model/user_info_model.dart';
import 'package:orre/provider/timer_state_notifier.dart';

final isObscureProvider = StateProvider<bool>((ref) => true);
final signUpFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final signUpPhoneNumberFormKeyProvider =
    Provider((ref) => GlobalKey<FormState>());

class SignUpScreen extends ConsumerWidget {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();

  final FocusNode nicknameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode authCodeFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscure = ref.watch(isObscureProvider);
    final formKey = ref.watch(signUpFormKeyProvider);

    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.25),
          child: StaticAppBarWidget(
            title: '회원 가입',
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
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
                    SizedBox(
                      height: 60,
                    ),
                    // 닉네임 입력창
                    TextInputWidget(
                      prefixIcon: Icon(Icons.person),
                      hintText: '닉네임을 입력해주세요.',
                      subTitle: '한글, 영문, 숫자를 포함한 2자 이상 10자 미만',
                      isObscure: false,
                      type: TextInputType.text,
                      ref: ref,
                      controller: nicknameController,
                      autofillHints: [
                        AutofillHints.name,
                      ],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-zA-Zㄱ-ㅎ가-힣]'))
                      ],
                      minLength: 2,
                      maxLength: 10,
                      focusNode: nicknameFocusNode,
                      nextFocusNode: passwordFocusNode,
                    ),
                    SizedBox(height: 16),
                    // 비밀번호 입력창
                    TextInputWidget(
                      subTitle: '영문, 숫자, 특수문자를 모두 포함한 8자 이상 20자 미만',
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
                      minLength: 8,
                      maxLength: 20,
                      focusNode: passwordFocusNode,
                      nextFocusNode: phoneNumberFocusNode,
                    ),
                    SizedBox(height: 16),
                    // 전화번호 입력창 및 인증번호 요청 버튼
                    Consumer(
                      builder: (context, ref, child) {
                        final timer = ref.watch(timerProvider);
                        final phoneFormKey =
                            ref.watch(signUpPhoneNumberFormKeyProvider);
                        return Form(
                          key: phoneFormKey,
                          child: TextInputWidget(
                            prefixIcon: Icon(Icons.phone),
                            hintText: '전화번호를 입력해주세요.',
                            subTitle: '-를 제외한 010으로 시작하는 숫자만 입력해주세요.',
                            isObscure: false,
                            type: TextInputType.number,
                            ref: ref,
                            autofillHints: [AutofillHints.telephoneNumber],
                            controller: phoneNumberController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            minLength: 11,
                            maxLength: 11,
                            focusNode: phoneNumberFocusNode,
                            nextFocusNode: authCodeFocusNode,
                            suffixIcon: TextButtonWidget(
                              onPressed: () {
                                if (!phoneFormKey.currentState!.validate()) {
                                  return;
                                }
                                print("authRequestTimer: $timer");
                                if (timer == 0) {
                                  // 버튼 클릭시 phoneNumberController에서 전화번호를 읽어서 사용
                                  String phoneNumber = phoneNumberController
                                      .text
                                      .replaceAll(RegExp(r'[^0-9]'), '');
                                  requestAuthCode(phoneNumber).then((value) {
                                    if (value == true) {
                                      ref
                                          .read(timerProvider.notifier)
                                          .setAndStartTimer(300);

                                      FocusScope.of(context)
                                          .requestFocus(authCodeFocusNode);
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Builder(
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertPopupWidget(
                                                  title: '인증번호 요청 실패',
                                                  subtitle:
                                                      '입력하신 전화번호가 이미 가입되어 있습니다.',
                                                  buttonText: '확인',
                                                ),
                                              ));
                                    }
                                  });
                                }
                              },
                              text: timer == 0
                                  ? "인증 번호 받기"
                                  : timer.toString() + "초 후 재시도",
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16),
                    // 인증번호 입력창
                    TextInputWidget(
                      hintText: '인증번호를 입력해주세요.',
                      isObscure: false,
                      type: TextInputType.number,
                      autofillHints: [AutofillHints.oneTimeCode],
                      ref: ref,
                      controller: authCodeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      prefixIcon: Icon(Icons.mark_as_unread_sharp),
                      minLength: 6,
                      maxLength: 6,
                      focusNode: authCodeFocusNode,
                    ),
                    SizedBox(height: 32),
                    // 하단 "회원 가입하기" 버튼
                    BigButtonWidget(
                      text: '회원 가입하기',
                      textColor: Colors.white,
                      onPressed: () {
                        final signUpUserInfo = SignUpInfo(
                          nickname: nicknameController.text,
                          password: passwordController.text,
                          phoneNumber: phoneNumberController.text
                              .replaceAll(RegExp(r'[^0-9]'), ''),
                          authCode: authCodeController.text,
                        );
                        print(signUpUserInfo.nickname);
                        print(signUpUserInfo.password);
                        print(signUpUserInfo.phoneNumber);
                        print(signUpUserInfo.authCode);
                        requestSignUp(signUpUserInfo).then((value) {
                          if (value == true) {
                            Future.delayed(Duration.zero, () {
                              ref.read(timerProvider.notifier).cancelTimer();
                              ref
                                  .read(userInfoProvider.notifier)
                                  .updateUserInfo(
                                    UserInfo(
                                      phoneNumber: signUpUserInfo.phoneNumber,
                                      password: signUpUserInfo.password,
                                      name: signUpUserInfo.nickname,
                                      fcmToken: '',
                                    ),
                                  );
                            });
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return MainScreen();
                            }));
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => Builder(
                                      builder: (BuildContext context) =>
                                          AlertPopupWidget(
                                        title: '회원가입 실패',
                                        buttonText: '확인',
                                      ),
                                    ));
                          }
                        });
                      },
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

Future<bool> requestAuthCode(String phoneNumber) async {
  try {
    final body = {
      'userPhoneNumber': phoneNumber,
    };
    final jsonBody = json.encode(body);
    final response = await HttpsService.postRequest(
        "/signup/generate-verification-code", jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      print("requestAuthCode(json 200): $jsonBody");
      if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
        print("requestAuthCode: success");
        return true;
      } else {
        print(
            "requestAuthCode: failed: ${APIResponseStatusExtension.fromCode(jsonBody['status']).toKoKr()}");
        return false;
      }
    } else {
      throw Exception('Failed to request AuthCode');
    }
  } catch (error) {
    throw Exception('Failed to requestAuthCode');
  }
}

Future<bool> requestSignUp(SignUpInfo signUpInfo) async {
  try {
    final body = {
      'userPhoneNumber': signUpInfo.phoneNumber,
      'verificationCode': signUpInfo.authCode,
      'userPassword': signUpInfo.password,
      'username': signUpInfo.nickname,
    };
    final jsonBody = json.encode(body);
    final response =
        await HttpsService.postRequest("/signup/complete", jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      print("requestSignUp(json 200): $jsonBody");
      if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
        print("requestSignUp: success");
        return true;
      } else {
        print(
            "requestSignUp: failed: ${APIResponseStatusExtension.fromCode(jsonBody['status']).toKoKr()}");
        return false;
      }
    } else {
      throw Exception('Failed to fetch store info');
    }
  } catch (error) {
    throw Exception('Failed to fetch store info');
  }
}
