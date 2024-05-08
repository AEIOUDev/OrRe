import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmallButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;
  final Size maxSize;

  const SmallButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.maxSize = const Size(double.infinity, 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFB74D), maximumSize: maxSize),
    );
  }
}
