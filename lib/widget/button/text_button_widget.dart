import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/hardware/haptic_services.dart';
import 'package:orre/widget/text/text_widget.dart';

class TextButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;
  final Size maxSize;
  final Color textColor;
  final double fontSize;

  const TextButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.black,
    this.fontSize = 24,
    this.maxSize = const Size(double.infinity, 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        await HapticServices.vibrate(ref, CustomHapticsType.selection);
        onPressed();
      },
      child: TextWidget(
        text,
        color: textColor,
        fontSize: fontSize,
      ),
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFFFFFFBF52),
      ),
    );
  }
}
