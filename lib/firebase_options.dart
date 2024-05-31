// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKWT7cM_O-d9RCtwP5xS_yZd4XBtqfrqA',
    appId: '1:171129567626:web:7ca382d37414c50e2db073',
    messagingSenderId: '171129567626',
    projectId: 'orre-be',
    authDomain: 'orre-be.firebaseapp.com',
    storageBucket: 'orre-be.appspot.com',
    measurementId: 'G-B75ET8W50Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDn3yd5fD1WVRm-p_sn9K_9lYSrx8JgHdw',
    appId: '1:171129567626:android:a903ad078d8238f52db073',
    messagingSenderId: '171129567626',
    projectId: 'orre-be',
    storageBucket: 'orre-be.appspot.com',
    androidClientId: 'com.aeioudev.orre',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOBHAPNAeC7qwPDWF-CHHzv0r1X2aoZC0',
    appId: '1:171129567626:ios:a99856f8f5f31ba82db073',
    messagingSenderId: '171129567626',
    projectId: 'orre-be',
    storageBucket: 'orre-be.appspot.com',
    iosBundleId: 'com.aeioudev.orre',
  );
}
