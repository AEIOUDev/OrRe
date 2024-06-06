import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';

class TextInputWidget extends ConsumerWidget {
  final String hintText;
  final bool isObscure;
  final TextInputType type;
  final WidgetRef ref;
  final TextEditingController controller;
  final Iterable<String>? autofillHints;
  final String? title;
  final String? subTitle;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final List<TextInputFormatter>? inputFormatters;
  final int minLength;
  final int? maxLength;
  final bool isRequired;

  TextInputWidget({
    required this.hintText,
    required this.isObscure,
    required this.type,
    required this.ref,
    required this.controller,
    this.autofillHints,
    this.title,
    this.subTitle = '',
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.nextFocusNode,
    this.inputFormatters,
    this.minLength = 0,
    this.maxLength,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextWidget(
              title!,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBF52),
              fontSize: 16,
              textAlign: TextAlign.left,
            ),
          ),
        if (subTitle != null)
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
            child: TextWidget(
              subTitle!,
              fontSize: 12,
              color: Color(0xFFFFBF52),
            ),
          ),
        TextFormField(
            autovalidateMode: AutovalidateMode.always,
            validator: (text) => errorTextWidget(
                text!, minLength, maxLength, isRequired,
                isPassword:
                    (autofillHints?.contains(AutofillHints.password) == true)),
            controller: controller, // TextField에 TextEditingController를 연결
            autofillHints: autofillHints,
            autofocus: true,
            focusNode: focusNode,
            keyboardType: type,
            obscureText: isObscure,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Dovemayo_gothic',
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFB74D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDFDFDF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                counterText: '',
                prefixIcon: prefixIcon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 16),
                          prefixIcon!,
                          SizedBox(width: 16),
                        ],
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [suffixIcon!, SizedBox(width: 16)],
                      )
                    : null),
            maxLength: maxLength,
            onEditingComplete: () {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            },
            onFieldSubmitted: (value) {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            },
            onChanged: (text) {
              print(errorTextWidget(text, minLength, maxLength, isRequired,
                  isPassword:
                      autofillHints?.contains(AutofillHints.password) == true));
            }),
      ],
    );
  }
}

String? errorTextWidget(
    String text, int minLength, int? maxLength, bool isRequired,
    {bool isPassword = false}) {
  // 특수문자 범위를 확장하고 정확하게 이스케이프 처리
  String pattern = r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{8,20})';

  if (text.isEmpty && isRequired) {
    return '필수 입력 항목입니다.';
  } else if (text.length < minLength) {
    return '최소 $minLength자 이상 입력해주세요.';
  } else if (maxLength != null && text.length > maxLength) {
    return '최대 $maxLength자까지 입력 가능합니다.';
  }
  if (isPassword) {
    if (!RegExp(pattern).hasMatch(text)) {
      return '영문, 숫자, 특수문자를 포함해주세요.';
    }
  }
  return null;
}

class PhoneInputFormatter extends TextInputFormatter {
  static const kPhoneNumberPrefix = '010';

  // 텍스트 편집 업데이트를 처리하기 위해 formatEditUpdate 메서드를 재정의
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = _getFormattedPhoneNumber(newValue.text);

    // 업데이트된 선택과 함께 포맷된 텍스트를 반환
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  // 전화번호의 길이에 따라 형식을 지정하는 메서드
  String _getFormattedPhoneNumber(String value) {
    value = _cleanPhoneNumber(value);

    //값이 없을 때 010최초값 포멧
    if (value.length == 1) {
      value = kPhoneNumberPrefix + value.substring(0, value.length);
    }
    // 010 을 지우지 못하도록 010 유지
    else if (value.length < 3) {
      value = kPhoneNumberPrefix;
    } else if (value.length > 11) {
      if (value.startsWith("8210")) {
        value = kPhoneNumberPrefix + value.substring(4, 12);
      } else if (value.startsWith("82010")) {
        value = kPhoneNumberPrefix + value.substring(5, 13);
      } else {}
    }
    // 010xxxxxxxx 포멧
    else if (value.length >= 8 && value.length < 12) {
      value =
          '$kPhoneNumberPrefix${value.substring(3, 7)}${value.substring(7, value.length)}';
    } else {
      // 010xxxx 포멧 (자릿수 제한은 inputformatters 로 구현)
      value = kPhoneNumberPrefix + value.substring(3, value.length);
    }

    return value;
  }

  // 입력에서 숫자가 아닌 문자를 제거하는 메서드
  String _cleanPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
