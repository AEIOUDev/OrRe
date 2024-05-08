import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarWidget extends ConsumerWidget {
  final String title;
  final double fontSize;
  final double leadingWidth;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.fontSize = 40,
    this.leadingWidth = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.left,
        ),
      ),
      backgroundColor: Colors.transparent,
      toolbarHeight: fontSize,
      leadingWidth: 300,
    );
  }
}
