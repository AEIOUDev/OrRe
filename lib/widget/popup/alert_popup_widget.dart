import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertPopupWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final Function()? onPressed;
  final bool autoPop;
  final bool cancelButton;

  const AlertPopupWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    this.onPressed,
    this.autoPop = true,
    this.cancelButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: TextWidget(
        title,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 66, 49, 21),
      ),
      content: (subtitle != null)
          ? TextWidget(
              subtitle!,
              textAlign: TextAlign.center,
              softWrap: true,
              fontSize: 20.sp,
              color: Color.fromARGB(255, 66, 49, 21),
            )
          : null,
      actions: <Widget>[
        if (cancelButton)
          Container(
            width: double.infinity, // 버튼을 AlertDialog의 가로 길이에 맞추기 위해
            child: SmallButtonWidget(
              minSize: Size(double.infinity, 50),
              text: '취소',
              onPressed: () {
                context.pop();
              },
            ),
            margin: EdgeInsets.only(bottom: 8),
          ),
        Container(
          width: double.infinity, // 버튼을 AlertDialog의 가로 길이에 맞추기 위해
          child: SmallButtonWidget(
            minSize: Size(double.infinity, 50),
            text: buttonText,
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
              }
              if (autoPop) context.pop();
            },
          ),
        ),
      ],
    );
  }
}
