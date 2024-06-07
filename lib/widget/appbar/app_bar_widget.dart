import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends ConsumerWidget {
  final String title;
  final double fontSize;
  final double contentHeight;
  final Widget? leading;
  final List<Widget>? actions;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.fontSize = 40,
    this.contentHeight = 400,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBarBuilder(
      backgroundColorAll: Color(0xFFFFBF52),
      backgroundColorBar: Colors.transparent,
      debug: false,
      barHeight: 50,
      initialBarHeight: 50,
      pinned: true,
      leadingActions: [
        (context, expandRatio, barHeight, overlapsContent) {
          return Row(
            children: [
              leading ?? SizedBox(width: 20),
            ],
          );
        }
      ],
      trailingActions: [
        (context, expandRatio, barHeight, overlapsContent) {
          return Row(
            children: [
              if (actions != null) ...actions!,
            ],
          );
        }
      ],
      initialContentHeight: contentHeight,
      contentBuilder: (
        context,
        expandRatio,
        contentHeight,
        centerPadding,
        overlapsContent,
      ) {
        return Stack(
          children: [
            // All height image that fades away on scroll.
            Opacity(
              opacity: expandRatio,
              child: ShaderMask(
                shaderCallback: _shaderCallback,
                blendMode: BlendMode.dstIn,
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/waveform/wave_shadow.png",
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/images/waveform/wave.png",
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),

            // Using alignment and padding, centers text to center of bar.
            Container(
              alignment: Alignment.centerLeft,
              height: contentHeight,
              padding: centerPadding.copyWith(
                left: 10 + (1 - expandRatio) * 40,
              ),
              child: Material(
                color: Colors.transparent,
                child: TextWidget(
                  title,
                  fontSize: 20.sp + expandRatio * 2.h,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Color.lerp(
                            Colors.black,
                            Colors.transparent,
                            1 - expandRatio,
                          ) ??
                          Colors.transparent,
                      blurRadius: 10,
                      offset: const Offset(4, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Shader _shaderCallback(Rect rect) {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.black, Colors.transparent],
      stops: [0.6, 1],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  }
}
