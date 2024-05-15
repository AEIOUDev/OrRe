import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:orre/model/user_info_model.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userInfoProvider =
    StateNotifierProvider<UserInfoProvider, UserInfo?>((ref) {
  return UserInfoProvider();
});

class UserInfoProvider extends StateNotifier<UserInfo?> {
  UserInfoProvider() : super(null);

  final _storage = FlutterSecureStorage();

  void updateUserInfo(UserInfo userInfo) {
    state = userInfo;
    saveUserInfo();
  }

  void saveUserInfo() {
    _storage.write(key: 'userPhoneNumber', value: state?.phoneNumber);
    _storage.write(key: 'userPassword', value: state?.password);
    _storage.write(key: 'name', value: state?.name);
    _storage.write(key: 'fcmToken', value: state?.fcmToken);
  }

  Future<bool> loadUserInfo() async {
    final isNull = !(await _storage.containsKey(key: 'userPhoneNumber'));
    if (isNull) {
      state = null;
      return false;
    } else {
      final phoneNumber = await _storage.read(key: 'userPhoneNumber');
      final password = await _storage.read(key: 'userPassword');
      final name = await _storage.read(key: 'name');
      final fcmToken = await _storage.read(key: 'fcmToken');

      state = UserInfo(
        phoneNumber: phoneNumber!,
        password: password!,
        name: name!,
        fcmToken: fcmToken!,
      );
      return true;
    }
  }

  Future<String?> requestSignIn(SignInInfo? signInInfo) async {
    try {
      print("로그인 시도 : $signInInfo");
      SignInInfo? info;

      final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      print("fcmToken : " + fcmToken);

      // 매개변수가 없다면 저장된 로그인 정보를 불러옴
      if (signInInfo == null) {
        final loaded = await loadUserInfo();
        print("loadUserInfo: $loaded");
        // 저장된 정보가 있다면
        if (loaded) {
          // 해당 정보로 로그인 시도
          info = SignInInfo(
            phoneNumber: state!.phoneNumber,
            password: state!.password,
          );
        } else {
          // 매개변수도 없고 저장된 정보도 없다면
          return null; // null 반환하여 로그인 화면으로 이동
        }
      } else {
        // 매개변수가 있다면 해당 매개변수로 로그인 시도
        info = signInInfo;
      }

      final body = {
        'userPhoneNumber': info.phoneNumber,
        'userPassword': info.password,
        'userFcmToken': fcmToken,
      };

      final jsonBody = json.encode(body);

      final response = await HttpsService.postRequest("/login", jsonBody);

      // 로그인 요청 성공 시
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        print("로그인 시도(json 200): $jsonResponse");
        if (APIResponseStatus.success.isEqualTo(jsonResponse['status'])) {
          print("로그인 시도: success");
          print("fcmToken : " + fcmToken);
          state = UserInfo(
            phoneNumber: info.phoneNumber,
            password: info.password,
            name: jsonResponse['token'],
            fcmToken: fcmToken ?? '', // TODO : fcmToken 추가
          );
          saveUserInfo();
          return jsonResponse['token'];
        } else {
          print(
              "로그인 시도: failed : Status Code ${APIResponseStatusExtension.fromCode(jsonResponse['status'])}");
        }
      } else {
        print("로그인 시도: failed : response code ${response.statusCode}");
      }
    } catch (error) {
      print("로그인 시도: error $error");
    }
    // 로그인 성공 못했을 시 null 반환하여 로그인 화면으로 이동
    return null;
  }

  UserInfo? getUserInfo() {
    return state;
  }

  Future<bool> withdraw() async {
    final userInfo = state;
    if (userInfo == null) {
      return false;
    }
    final phoneNumber = userInfo.phoneNumber;
    final password = userInfo.password;
    final name = userInfo.name;

    final body = {
      'userPhoneNumber': phoneNumber,
      'userPassword': password,
      'username': name,
    };
    final jsonBody = json.encode(body);
    final response = await HttpsService.postRequest("/signup/remove", jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
        clearUserInfo();
        return true;
      } else {
        print(
            "Failed to withdrawal ${APIResponseStatusExtension.fromCode(jsonBody['status'])}");
        return false;
      }
    } else {
      throw Exception('Failed to withdrawal');
    }
  }

  void clearUserInfo() {
    state = null;
    _storage.delete(key: 'userPhoneNumber');
    _storage.delete(key: 'userPassword');
    _storage.delete(key: 'name');
    _storage.delete(key: 'fcmToken');
    _storage.readAll().then((value) => print(value));
    _storage.read(key: 'userPhoneNumber').then((value) => print(value));
  }
}
