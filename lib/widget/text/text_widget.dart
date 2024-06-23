import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TextSize { small, medium, large }

class TextWidget extends ConsumerWidget {
  final String text;
  final double fontSize;
  final Color color;
  final String fontFamily;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final bool softWrap;
  final List<Shadow> shadows;
  final double wordSpacing;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;
  final TextOverflow overflow;
  final int maxLines;

  const TextWidget(
    this.text, {
    Key? key,
    this.fontSize = 24,
    this.color = Colors.black,
    this.fontFamily = 'Dovemayo_gothic',
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.normal,
    this.softWrap = true,
    this.shadows = const [],
    this.wordSpacing = 0,
    this.letterSpacing = 0,
    this.padding = const EdgeInsets.all(0),
    this.overflow = TextOverflow.clip,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: padding,
      child: Text(text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            shadows: shadows,
            wordSpacing: wordSpacing,
            letterSpacing: letterSpacing,
          ),
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
          locale: Locale('ko', 'KR')),
    );
  }
}
