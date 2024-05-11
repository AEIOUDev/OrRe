import 'dart:convert';

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
      print("requestSignIn: $signInInfo");
      late SignInInfo info;

      // storage에 저장된 정보로 로그인하는 경우
      if (signInInfo == null) {
        await loadUserInfo().then((value) {
          print("loadUserInfo: $value");
          if (value) {
            info = SignInInfo(
              phoneNumber: state!.phoneNumber,
              password: state!.password,
            );
          } else {
            return null;
          }
        });
      } else {
        info = signInInfo;
      }
      final body = {
        'userPhoneNumber': info.phoneNumber,
        'userPassword': info.password,
      };
      final jsonBody = json.encode(body);
      final response = await HttpsService.postRequest("/login", jsonBody);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        print("requestSignIn(json 200): $jsonBody");
        if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
          print("requestSignIn: success");
          state = UserInfo(
            phoneNumber: info.phoneNumber,
            password: info.password,
            name: jsonBody['token'],
            fcmToken: '',
          );
          saveUserInfo();
          return jsonBody['token'];
        } else {
          print("requestSignIn: failed");
          return null;
        }
      } else {
        throw Exception('Failed to request sign in');
      }
    } catch (error) {
      throw Exception('Failed to request sign in');
    }
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
