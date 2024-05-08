import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;
  final Size maxSize;

  const TextButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.maxSize = const Size(double.infinity, 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        onPressed();
      },
      child: Text(text),
    );
  }
}
