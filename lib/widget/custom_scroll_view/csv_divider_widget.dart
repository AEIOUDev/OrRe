import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CSVDividerWidget extends ConsumerWidget {
  final Color? color;
  final double? height;

  const CSVDividerWidget({Key? key, this.color, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Divider(
        color: color ?? Colors.grey,
        height: height ?? 1.0,
      ),
    );
  }
}
