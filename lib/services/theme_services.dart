import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrreFont {
  static double caption = 12.sp;
  static double body = 16.sp;
  static double headline = 20.sp;
  static double title = 24.sp;
  static double largeTitle = 28.sp;
  static double display = 32.sp;

  static const String dovemayoFont = "Dovemayo_gothic";
  static const String androidFont = "NotoSansKR";
  static const String iosFont = "AppleSDGothicNeo";
}

class OrreThemeSystem {
  final TextTheme theme;

  OrreThemeSystem(this.theme);

  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: OrreFont.largeTitle,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      displayMedium: TextStyle(
        fontSize: OrreFont.title,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      displaySmall: TextStyle(
        fontSize: OrreFont.headline,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      titleLarge: TextStyle(
        fontSize: OrreFont.title,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      titleMedium: TextStyle(
        fontSize: OrreFont.headline,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      titleSmall: TextStyle(
        fontSize: OrreFont.body,
        fontWeight: FontWeight.bold,
        fontFamily: OrreFont.dovemayoFont,
      ),
      bodyLarge: TextStyle(
        fontSize: OrreFont.body,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      bodyMedium: TextStyle(
        fontSize: OrreFont.caption,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      bodySmall: TextStyle(
        fontSize: OrreFont.caption,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      headlineLarge: TextStyle(
        fontSize: OrreFont.headline,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      headlineMedium: TextStyle(
        fontSize: OrreFont.body,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      headlineSmall: TextStyle(
        fontSize: OrreFont.caption,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      labelLarge: TextStyle(
        fontSize: OrreFont.body,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      labelMedium: TextStyle(
        fontSize: OrreFont.caption,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
      labelSmall: TextStyle(
        fontSize: OrreFont.caption,
        fontWeight: FontWeight.normal,
        fontFamily: OrreFont.dovemayoFont,
      ),
    );
  }
}
