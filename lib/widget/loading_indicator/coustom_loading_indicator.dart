import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/loading_orre.gif', // 이미지의 경로 지정
        width: 200.w, // 이미지의 가로 크기
        height: 200.h, // 이미지의 세로 크기
      ),
    );
  }
}
