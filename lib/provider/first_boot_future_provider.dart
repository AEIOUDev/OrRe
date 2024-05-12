// 처음 부팅할 때 필요한 초기화 작업을 수행하는 Provider

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/error_state_notifier.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/provider/network/connectivity_state_notifier.dart';
import 'package:orre/provider/network/websocket/stomp_client_state_notifier.dart';
import 'package:orre/provider/userinfo/user_info_state_notifier.dart';

final firstBootState = StateProvider<bool>((ref) => false);

final signInProvider = FutureProvider<void>((ref) async {
  print("signInProvider start");
  Completer<void> completer = Completer();

  // networkStreamProvider를 구독하고, true가 되면 작업을 수행
  ref.listen<bool>(networkStateNotifier, (prevState, newState) {
    print("Network status: $newState");
    if (newState) {
      print("Network is connected, attempting to sign in...");
      ref.read(userInfoProvider.notifier).requestSignIn(null).then((value) {
        if (value == null) {
          print("Sign in failed: $value");
          completer.completeError("sigin in failed");
        } else {
          print("Sign in success");
          completer.complete();
        }
      }).catchError((error) {
        print("Sign in error: $error");
        completer.completeError(error);
      });
    } else {
      print("Network is not connected, waiting...");
    }
  });

  // Completer의 Future를 반환하여, 외부에서 signInProvider의 완료를 기다릴 수 있도록 함
  await completer.future;
});

final firstBootFutureProvider = FutureProvider<void>((ref) async {
  final Completer<void> completer = Completer();
  if (ref.watch(firstBootState.notifier).state) {
    print("already booted");
    return;
  }

  print("first boot start");
  try {
    await ref.read(signInProvider.future);
  } catch (error) {
    print("sign in error: $error");
    completer.completeError(error);
  } finally {
    await ref
        .read(stompClientStateNotifierProvider.notifier)
        .configureClient()
        .listen((event) {
      print("!!!!!!!!!!!!!!!!event: $event");
      if (event == StompStatus.CONNECTED) {
        print("websocket connected");
        ref
            .read(errorStateNotifierProvider.notifier)
            .deleteError(Error.websocket);
        ref
            .read(nowLocationProvider.notifier)
            .updateNowLocation()
            .then((value) {
          if (value == LocationInfo.nullValue()) {
            print("nowLocation not updated");
            ref
                .read(errorStateNotifierProvider.notifier)
                .addError(Error.locationPermission);
          } else {
            print("nowLocation updated");
            ref
                .read(errorStateNotifierProvider.notifier)
                .deleteError(Error.locationPermission);
            ref.watch(firstBootState.notifier).state = true;
          }
        });
      } else {
        print("websocket disconnected");
        ref.read(errorStateNotifierProvider.notifier).addError(Error.websocket);
      }
      print("end of websocket event");
      completer.complete();
    });
  }
});
