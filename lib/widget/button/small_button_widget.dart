import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmallButtonWidget extends ConsumerWidget {
  final String text;
  final Function onPressed;
  final Size minSize;
  final Size maxSize;

  const SmallButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.minSize = const Size(50, 50),
    this.maxSize = const Size(double.infinity, 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      child: TextWidget(
        text,
        fontSize: 20.sp,
        color: Colors.white,
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Color(0xFFFFBF52),
        maximumSize: maxSize,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
      ),
    );
  }
}
