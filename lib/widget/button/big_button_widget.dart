import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BigButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;

  const BigButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFB74D),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
