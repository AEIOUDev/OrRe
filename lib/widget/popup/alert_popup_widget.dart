import 'package:flutter/material.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/button/small_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

class AlertPopupWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;

  const AlertPopupWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.buttonText,
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
              fontSize: 20,
              color: Color.fromARGB(255, 66, 49, 21),
            )
          : null,
      actions: <Widget>[
        Container(
          width: double.infinity, // 버튼을 AlertDialog의 가로 길이에 맞추기 위해
          child: SmallButtonWidget(
            minSize: Size(double.infinity, 50),
            text: buttonText,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}