import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaticAppBarWidget extends ConsumerWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor; // 추가된 속성

  const StaticAppBarWidget({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.transparent, // 기본값 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: backgroundColor, // 배경 색 적용
      padding: EdgeInsets.only(top: 60, left: 5),
      child: Row(
        children: [
          leading ?? SizedBox(width: 20),
          TextWidget(
            title,
            fontSize: 20.sp,
            color: Colors.black,
          ),
          Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
