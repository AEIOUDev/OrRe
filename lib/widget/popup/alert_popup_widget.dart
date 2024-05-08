import 'package:flutter/material.dart';
import 'package:orre/widget/button/big_button_widget.dart';

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
      title: Text(title,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 25)),
      content: (subtitle != null)
          ? Text(subtitle!,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
          : null,
      actions: [
        Center(
          child: BigButtonWidget(
            text: buttonText,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
