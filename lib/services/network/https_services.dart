import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:orre/services/debug_services.dart';

enum APIResponseStatus {
  success,
  signInFailure,
  authCodeGenFailure,
  authCodeMatchFailure,
  withdrawFailure,
  resetPasswordPhoneNumberFailure,
  resetPasswordAuthCodeFailure,
  userJWTValidationFailure,
  userOrderFauilure,
  returnCalculationResultFailure,
  waitingJoinFailure,
  waitingExitFailure,
  waitingCancelByStore,
  waitingCancelByStoreCancel,
  waitingEnteringSuccess,
  waitingAlreadyJoin,
  serviceLogEmpty,
  serviceLogPhoneNumberFailure,
  appVersionDifferent,
  etc
}

extension APIResponseStatusExtension on APIResponseStatus {
  String toKoKr() {
    switch (this) {
      case APIResponseStatus.success:
        return '성공';
      case APIResponseStatus.signInFailure:
        return '로그인 실패';
      case APIResponseStatus.authCodeGenFailure:
        return '인증번호 생성 실패';
      case APIResponseStatus.authCodeMatchFailure:
        return '인증번호 불일치';
      case APIResponseStatus.withdrawFailure:
        return '회원탈퇴 실패';
      case APIResponseStatus.resetPasswordPhoneNumberFailure:
        return '비밀번호 재설정 실패 : 일치하는 전화번호 없음';
      case APIResponseStatus.resetPasswordAuthCodeFailure:
        return '비밀번호 재설정 실패: 인증번호 불일치';
      case APIResponseStatus.userJWTValidationFailure:
        return '유저 JWT 검증 실패';
      case APIResponseStatus.userOrderFauilure:
        return '유저 주문 실패';
      case APIResponseStatus.returnCalculationResultFailure:
        return '반환 계산 결과 실패';
      case APIResponseStatus.waitingJoinFailure:
        return '대기열 참가 실패';
      case APIResponseStatus.waitingExitFailure:
        return '대기열 나가기 실패';
      case APIResponseStatus.waitingCancelByStore:
        return '가게에 의한 대기열 취소';
      case APIResponseStatus.waitingCancelByStoreCancel:
        return '가게 영업 마감에 의한 대기열 취소';
      case APIResponseStatus.waitingEnteringSuccess:
        return '대기열 입장 성공';
      case APIResponseStatus.waitingAlreadyJoin:
        return '이미 대기열에 참가 중';
      case APIResponseStatus.serviceLogEmpty:
        return '서비스 로그 조회 결과 없음';
      case APIResponseStatus.serviceLogPhoneNumberFailure:
        return '서비스 로그 조회 실패: 일치하는 전화번호 없음';
      case APIResponseStatus.appVersionDifferent:
        return '필수 업데이트 필요';
      default:
        return '기타';
    }
  }

  String toEnUs() {
    switch (this) {
      case APIResponseStatus.success:
        return 'Success';
      case APIResponseStatus.signInFailure:
        return 'Sign in failure';
      case APIResponseStatus.authCodeGenFailure:
        return 'Auth code generation failure';
      case APIResponseStatus.authCodeMatchFailure:
        return 'Auth code mismatch';
      case APIResponseStatus.withdrawFailure:
        return 'Withdraw failure';
      case APIResponseStatus.resetPasswordPhoneNumberFailure:
        return 'Reset password failure: No matching phone number';
      case APIResponseStatus.resetPasswordAuthCodeFailure:
        return 'Reset password failure: Auth code mismatch';
      case APIResponseStatus.userJWTValidationFailure:
        return 'User JWT validation failure';
      case APIResponseStatus.userOrderFauilure:
        return 'User order failure';
      case APIResponseStatus.returnCalculationResultFailure:
        return 'Return calculation result failure';
      case APIResponseStatus.waitingJoinFailure:
        return 'Waiting join failure';
      case APIResponseStatus.waitingExitFailure:
        return 'Waiting exit failure';
      case APIResponseStatus.waitingCancelByStore:
        return 'Waiting cancel by store';
      case APIResponseStatus.waitingCancelByStoreCancel:
        return 'Waiting cancel by store close';
      case APIResponseStatus.waitingEnteringSuccess:
        return 'Waiting entering success';
      case APIResponseStatus.waitingAlreadyJoin:
        return 'Already joined in waiting';
      case APIResponseStatus.serviceLogEmpty:
        return 'Service log empty';
      case APIResponseStatus.serviceLogPhoneNumberFailure:
        return 'Service log failure: No matching phone number';
      case APIResponseStatus.appVersionDifferent:
        return 'Essential update required';
      default:
        return 'Etc';
    }
  }

  String toCode() {
    switch (this) {
      case APIResponseStatus.signInFailure:
        return '601';
      case APIResponseStatus.authCodeGenFailure:
        return '701';
      case APIResponseStatus.authCodeMatchFailure:
        return '702';
      case APIResponseStatus.resetPasswordPhoneNumberFailure:
        return '703';
      case APIResponseStatus.resetPasswordAuthCodeFailure:
        return '704';
      case APIResponseStatus.withdrawFailure:
        return '801';
      case APIResponseStatus.userJWTValidationFailure:
        return '901';
      case APIResponseStatus.userOrderFauilure:
        return '902';
      case APIResponseStatus.returnCalculationResultFailure:
        return '1001';
      case APIResponseStatus.waitingJoinFailure:
        return '1101';
      case APIResponseStatus.waitingExitFailure:
        return '1102';
      case APIResponseStatus.waitingCancelByStore:
        return '1103';
      case APIResponseStatus.waitingEnteringSuccess:
        return '1104';
      case APIResponseStatus.waitingAlreadyJoin:
        return '1105';
      case APIResponseStatus.waitingCancelByStoreCancel:
        return '1106';
      case APIResponseStatus.serviceLogEmpty:
        return '1201';
      case APIResponseStatus.serviceLogPhoneNumberFailure:
        return '1202';
      case APIResponseStatus.appVersionDifferent:
        return '1301';

      case APIResponseStatus.success:
        return '200';
      default:
        return 'etc';
    }
  }

  static APIResponseStatus fromCode(String code) {
    switch (code) {
      case '200':
        return APIResponseStatus.success;
      case '601':
        return APIResponseStatus.signInFailure;
      case '701':
        return APIResponseStatus.authCodeGenFailure;
      case '702':
        return APIResponseStatus.authCodeMatchFailure;
      case '703':
        return APIResponseStatus.resetPasswordPhoneNumberFailure;
      case '704':
        return APIResponseStatus.resetPasswordAuthCodeFailure;
      case '801':
        return APIResponseStatus.withdrawFailure;
      case '901':
        return APIResponseStatus.userJWTValidationFailure;
      case '902':
        return APIResponseStatus.userOrderFauilure;
      case '1001':
        return APIResponseStatus.returnCalculationResultFailure;
      case '1101':
        return APIResponseStatus.waitingJoinFailure;
      case '1102':
        return APIResponseStatus.waitingExitFailure;
      case '1103':
        return APIResponseStatus.waitingCancelByStore;
      case '1104':
        return APIResponseStatus.waitingEnteringSuccess;
      case '1105':
        return APIResponseStatus.waitingAlreadyJoin;
      case '1106':
        return APIResponseStatus.waitingCancelByStoreCancel;
      case '1201':
        return APIResponseStatus.serviceLogEmpty;
      case '1202':
        return APIResponseStatus.serviceLogPhoneNumberFailure;
      case '1301':
        return APIResponseStatus.appVersionDifferent;

      default:
        return APIResponseStatus.etc;
    }
  }

  bool isEqualTo(String other) {
    return toCode() == other;
  }
}

class HttpsService {
  static final String _uniUrl = dotenv.get('ORRE_HTTPS_UNI_URL');
  static final String _defaultUrl = dotenv.get('ORRE_HTTPS_DEFAULT_URL');

  static Uri getUri(String url) {
    return Uri.parse(_defaultUrl + url);
  }

  static Uri getUniUri(String url) {
    return Uri.parse(_uniUrl + url);
  }

  static Future<http.Response> postRequest(String url, String jsonBody) async {
    printd('jsonBody: $jsonBody');
    printd('post url: ${getUri(url)}');
    final response = await http.post(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    printd('response: ${response.body}');
    return response;
  }

  static Future<http.Response> getRequest(String url) async {
    printd('get url: ${getUri(url)}');
    final response = await http.get(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }

  static Future<http.Response> getUniRequest(String url) async {
    printd('get url: ${getUniUri(url)}');
    final response = await http.get(
      getUniUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }

  static Future<http.Response> postUniRequest(
      String url, String jsonBody) async {
    printd('jsonBody: $jsonBody');
    printd('post url: ${getUniUri(url)}');
    final response = await http.post(
      getUniUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    printd('response: ${response.body}');
    return response;
  }
}
