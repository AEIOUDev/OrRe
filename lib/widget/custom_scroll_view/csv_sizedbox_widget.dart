import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CSVSizedBoxWidget extends ConsumerWidget {
  final double? height;
  final double? width;

  const CSVSizedBoxWidget({this.height, this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        width: width,
      ),
    );
  }
}
