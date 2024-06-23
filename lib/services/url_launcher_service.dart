import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

Future<void> launchUpdateURL() async {
  String url = '';
  if (Platform.isAndroid) {
    url = 'https://play.google.com/store/apps/details?id=com.aeioudev.orre';
  } else if (Platform.isIOS) {
    url = 'https://apps.apple.com/kr/app/id6503636795';
  } else {
    throw 'Could not launch URL';
  }

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch URL';
  }
}
