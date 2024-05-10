import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';

class BigButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;
  final Color backgroundColor;
  final Size minimumSize;
  final OutlinedBorder shape;

  const BigButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFFFB74D),
    this.minimumSize = const Size(double.infinity, 50),
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      child: TextWidget(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: minimumSize,
        shape: shape,
      ),
    );
  }
}
