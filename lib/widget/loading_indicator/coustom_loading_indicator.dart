import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';

class CustomLoadingIndicator extends ConsumerWidget {
  final String? message;

  CustomLoadingIndicator({this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/loading_orre.gif', // 이미지의 경로 지정
            width: 200.w, // 이미지의 가로 크기
            height: 200.h, // 이미지의 세로 크기
          ),
          SizedBox(
            height: 16.h,
          ),
          if (message != null)
            TextWidget(
              message!,
              fontSize: 16.sp,
              color: Colors.black,
            )
          else
            SizedBox.shrink(),
        ],
      ),
    );
  }
}
