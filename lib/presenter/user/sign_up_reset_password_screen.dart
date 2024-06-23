import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/text_button_widget.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';

import 'package:orre/widget/text_field/text_input_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/provider/timer_state_notifier.dart';

import '../../services/debug_services.dart';

final isObscureProvider = StateProvider<bool>((ref) => true);

final phoneNumberFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final resetFormKeyProvider = Provider((ref) => GlobalKey<FormState>());

class SignUpResetPasswordScreen extends ConsumerWidget {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode authCodeFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\n SignUpResetPasswordScreen 진입");
    final isObscure = ref.watch(isObscureProvider);
    final formKey = ref.watch(resetFormKeyProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WaveformBackgroundWidget(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0.25.sh),
            child: StaticAppBarWidget(
              title: '비밀번호 재설정',
              leading: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 16 * 5),
                      // 전화번호 입력창 및 인증번호 요청 버튼
                      Consumer(
                        builder: (context, ref, child) {
                          final phoneNumberFormKey =
                              ref.watch(phoneNumberFormKeyProvider);
                          final timer = ref.watch(timerProvider);
                          return Form(
                            key: phoneNumberFormKey,
                            child: TextInputWidget(
                              prefixIcon: Icon(Icons.phone),
                              hintText: '전화번호를 입력해주세요.',
                              isObscure: false,
                              type: TextInputType.number,
                              ref: ref,
                              autofillHints: [AutofillHints.telephoneNumber],
                              controller: phoneNumberController,
                              inputFormatters: [
                                PhoneInputFormatter(),
                              ],
                              minLength: 11,
                              maxLength: 11,
                              focusNode: phoneNumberFocusNode,
                              nextFocusNode: authCodeFocusNode,
                              suffixIcon: TextButtonWidget(
                                  onPressed: () {
                                    if (!phoneNumberFormKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    printd("authRequestTimer: $timer");
                                    if (timer == 0) {
                                      // 버튼 클릭시 phoneNumberController에서 전화번호를 읽어서 사용
                                      String phoneNumber = phoneNumberController
                                          .text
                                          .replaceAll(RegExp(r'[^0-9]'), '');
                                      requestAuthCodeForReset(phoneNumber).then(
                                        (value) {
                                          printd("authCodeGen: $value");
                                          if (value ==
                                              APIResponseStatus.success) {
                                            printd("authCodeGenSuccess");
                                            ref
                                                .read(timerProvider.notifier)
                                                .setAndStartTimer(300);
                                            FocusScope.of(context).requestFocus(
                                                authCodeFocusNode);
                                          } else if (value ==
                                              APIResponseStatus
                                                  .resetPasswordPhoneNumberFailure) {
                                            AwesomeDialogWidget.showErrorDialog(
                                              context: context,
                                              title: '인증번호 요청 실패',
                                              desc: '일치하는 전화번호가 없습니다.',
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                  text: timer == 0
                                      ? "인증 번호 받기"
                                      : timer.toString() + "초 후 재시도",
                                  fontSize: 16.sp),
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
                        nextFocusNode: passwordFocusNode,
                      ),
                      SizedBox(height: 16),

                      // 비밀번호 입력창
                      TextInputWidget(
                        subTitle: '영문, 숫자, 특수문자를 모두 포함한 8자 이상 20자 미만',
                        hintText: '새로운 비밀번호를 입력해주세요.',
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
                      ),
                      SizedBox(height: 32),

                      // 하단 "회원 가입하기" 버튼
                      BigButtonWidget(
                        text: '비밀번호 재설정하기',
                        textColor: Colors.white,
                        onPressed: () {
                          if (formKey.currentState == null) return;

                          final FormState formState =
                              formKey.currentState as FormState;
                          if (!formState.validate()) {
                            return;
                          }
                          String phoneNumber = phoneNumberController.text
                              .replaceAll(RegExp(r'[^0-9]'), '');
                          String authCode = authCodeController.text;
                          String newPassword = passwordController.text;
                          requestResetPassword(
                                  phoneNumber, authCode, newPassword)
                              .then(
                            (value) {
                              if (value == true) {
                                Future.delayed(Duration.zero, () {
                                  ref
                                      .read(timerProvider.notifier)
                                      .cancelTimer();
                                });

                                context.go("/user/onboarding");

                                // showDialog(
                                //     context: context,
                                //     builder: (context) => Builder(
                                //           builder: (BuildContext context) =>
                                //               AlertPopupWidget(
                                //             title: '비밀번호 재설정 성공',
                                //             subtitle: '새로운 비밀번호로 로그인해주세요.',
                                //             buttonText: '확인',
                                //           ),
                                //         ));
                              } else {
                                AwesomeDialogWidget.showErrorDialog(
                                  context: context,
                                  title: '비밀번호 재설정 실패',
                                  desc: '인증번호 또는 전화번호를 확인해주세요.',
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<APIResponseStatus> requestAuthCodeForReset(String phoneNumber) async {
  try {
    final body = {
      'userPhoneNumber': phoneNumber,
    };
    final jsonBody = json.encode(body);
    final response = await HttpsService.postRequest(
        dotenv.get('ORRE_HTTPS_ENDPOINT_AUTHCODEFORRESETPASSWORD'), jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      printd("requestAuthCode(json 200): $jsonBody");
      printd(
          "requestAuthCode: ${APIResponseStatusExtension.fromCode(jsonBody['status']).toKoKr()}");
      return APIResponseStatusExtension.fromCode(jsonBody['status']);
    } else {
      throw Exception('Failed to request AuthCodeForReset');
    }
  } catch (error) {
    throw Exception('Failed to request AuthCodeForReset');
  }
}

Future<bool> requestResetPassword(
    String phoneNumber, String authCode, String newPassword) async {
  try {
    final body = {
      'userPhoneNumber': phoneNumber,
      'verificationCode': authCode,
      'userPassword': newPassword,
    };
    final jsonBody = json.encode(body);
    printd("requestResetPassword: $jsonBody");
    final response = await HttpsService.postRequest(
        dotenv.get('ORRE_HTTPS_ENDPOINT_RESETPASSWORD'), jsonBody);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      printd("requestResetPassword(json 200): $jsonBody");
      if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
        printd("requestResetPassword: success");
        return true;
      } else {
        printd(
            "requestResetPassword: failed: ${APIResponseStatusExtension.fromCode(jsonBody['status']).toKoKr()}");
        return false;
      }
    } else {
      throw Exception('Failed to ResetPassword');
    }
  } catch (error) {
    throw Exception('Failed to fetch ResetPassword');
  }
}
