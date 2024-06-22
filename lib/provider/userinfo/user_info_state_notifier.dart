import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orre/model/user_info_model.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/debug_services.dart';

final userInfoProvider =
    StateNotifierProvider<UserInfoProvider, UserInfo?>((ref) {
  return UserInfoProvider(ref);
});

class UserInfoProvider extends StateNotifier<UserInfo?> {
  late Ref ref;
  UserInfoProvider(this.ref) : super(null);

  final _storage = FlutterSecureStorage();

  void updateUserInfo(UserInfo userInfo) async {
    state = userInfo;
    await saveUserInfo();
  }

  Future<void> saveUserInfo() async {
    try {
      final userInfo = state;
      if (userInfo == null) {
        printd("saveUserInfo: userInfo is null");
        return;
      }
      printd("saveUserInfo: $userInfo");
      await _storage.write(key: 'userPhoneNumber', value: userInfo.phoneNumber);
      await _storage.write(key: 'userPassword', value: userInfo.password);
      await _storage.write(key: 'name', value: userInfo.name);
      await _storage.write(key: 'fcmToken', value: userInfo.fcmToken);
      printd("saveUserInfo: ${userInfo.phoneNumber}");
    } catch (error) {
      printd("saveUserInfo: error $error");
    }
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
    printd("로그인 시도 : $signInInfo");
    SignInInfo? info;

    final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    printd("fcmToken : " + fcmToken);

    // 매개변수가 없다면 저장된 로그인 정보를 불러옴
    if (signInInfo == null) {
      final loaded = await loadUserInfo();
      printd("loadUserInfo: $loaded");
      // 저장된 정보가 있다면
      if (loaded) {
        // 해당 정보로 로그인 시도
        if (state == null) {
          return null;
        } else {
          printd("state : $state");
          UserInfo user = state as UserInfo;
          info = SignInInfo(
            phoneNumber: user.phoneNumber,
            password: user.password,
          );
        }
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

    final response = await HttpsService.postRequest(
        dotenv.get('ORRE_HTTPS_ENDPOINT_SIGNIN'), jsonBody);

    // 로그인 요청 성공 시
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      printd("로그인 시도(json 200): $jsonResponse");
      if (APIResponseStatus.success.isEqualTo(jsonResponse['status'])) {
        printd("로그인 시도: success");
        // 기존 저장된 유저의 전화번호와 현재 로그인된 유저의 전화번호가 다르다면
        if (state?.phoneNumber != info.phoneNumber) {
          // 기존 유저 정보의 모든 정보 삭제
          await clearAllInfo();
        }
        printd("fcmToken : " + fcmToken);
        state = UserInfo(
          phoneNumber: info.phoneNumber,
          password: info.password,
          name: jsonResponse['token'],
          fcmToken: fcmToken, // fcmToken이 null이면 빈 문자열로 저장
        );
        await saveUserInfo();
        printd("로그인 성공 : ${state?.name}");
        printd("로그인 성공 : ${state?.phoneNumber}");
        printd("로그인 성공 : ${state?.password}");
        printd("로그인 성공 : ${state?.fcmToken}");

        return jsonResponse['token'];
      } else {
        printd(
            "로그인 시도: failed : Status Code ${APIResponseStatusExtension.fromCode(jsonResponse['status'])}");
      }
    } else {
      printd("로그인 시도: failed : response code ${response.statusCode}");
    }
    // // 로그인 성공 못했을 시 null 반환하여 로그인 화면으로 이동
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
    final response = await HttpsService.postRequest(
        dotenv.get('ORRE_HTTPS_ENDPOINT_WITHDRAW'), jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      if (APIResponseStatus.success.isEqualTo(jsonBody['status'])) {
        clearUserInfo();
        return true;
      } else {
        printd(
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
    _storage.readAll().then((value) => printd(value));
  }

  Future<void> clearAllInfo() async {
    printd("clearAllInfo");
    state = null;

    printd("state : $state");
    await _storage.deleteAll();

    printd("storage : ${await _storage.readAll()}");
    await SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
    });

    printd("sharedPreferences : ${await SharedPreferences.getInstance()}");
    // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  String? getNickname() {
    return state?.name ?? "사용자";
  }
}
