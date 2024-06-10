// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExtendBodyWidget extends ConsumerWidget {
  final Widget child;

  const ExtendBodyWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final MediaQueryData metrics = MediaQuery.of(context);

        final double bottom = true
            ? 0.0 // override to remove padding at the bottom
            : metrics.padding.bottom;

        final double top = true
            ? 0.0 // override to remove padding at the top
            : metrics.padding.top;
        return MediaQuery(
          data: metrics.copyWith(
            padding: metrics.padding.copyWith(
              top: top,
              bottom: bottom,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
