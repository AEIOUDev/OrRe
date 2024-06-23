import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AwesomeDialogWidget {
  static void showWarningDialog({
    required BuildContext context,
    required String title,
    required String desc,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {},
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: "확인",
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
    ).show();
  }

  static void showInfoDialog(
      {required BuildContext context,
      required String title,
      required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {},
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: "확인",
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
    ).show();
  }

  static void showSuccessDialog(
      {required BuildContext context,
      required String title,
      required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {},
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: "확인",
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
    ).show();
  }

  static void showErrorDialog(
      {required BuildContext context,
      required String title,
      required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {},
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: "확인",
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
    ).show();
  }

  static void showNoActionDialog(
      {required BuildContext context,
      required String title,
      required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {},
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: "확인",
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
    ).show();
  }

  static void showCustomDialog(
      {required BuildContext context,
      required String title,
      required String desc,
      required DialogType dialogType,
      required Function() onPressed,
      required String btnText}) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {
        onPressed();
      },
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: btnText,
    ).show();
  }

  static void showCustomDialogWithCancel({
    required BuildContext context,
    required String title,
    required String desc,
    required DialogType dialogType,
    required Function() onPressed,
    required String btnText,
    required Function() onCancel,
    required String cancelText,
    Widget? body,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      titleTextStyle: TextStyle(fontSize: 20.sp, fontFamily: 'Dovemayo_gothic'),
      descTextStyle: TextStyle(fontSize: 16.sp, fontFamily: 'Dovemayo_gothic'),
      btnOkOnPress: () {
        onPressed();
      },
      btnOkColor: Color(0xFFFFB74D),
      btnOkText: btnText,
      btnCancelOnPress: () {
        onCancel();
      },
      buttonsTextStyle: TextStyle(
          fontSize: 16.sp, fontFamily: 'Dovemayo_gothic', color: Colors.white),
      btnCancelColor: Color(0xFFFFB74D),
      btnCancelText: cancelText,
      body: body,
    ).show();
  }
}
