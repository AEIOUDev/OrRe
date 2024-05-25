import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/loading_orre.gif', // 이미지의 경로 지정
        width: 40, // 이미지의 가로 크기
        height: 40, // 이미지의 세로 크기
      ),
    );
  }
}