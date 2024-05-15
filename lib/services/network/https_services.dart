import 'package:http/http.dart' as http;

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
  waitingEnteringSuccess,
  serviceLogFailure,
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
      case APIResponseStatus.waitingEnteringSuccess:
        return '대기열 입장 성공';
      case APIResponseStatus.serviceLogFailure:
        return '서비스 로그 조회 결과 없음';

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
      case APIResponseStatus.waitingEnteringSuccess:
        return 'Waiting entering success';
      case APIResponseStatus.serviceLogFailure:
        return 'Service log failure';

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
      case APIResponseStatus.serviceLogFailure:
        return '1201';

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
      case '1201':
        return APIResponseStatus.serviceLogFailure;

      default:
        return APIResponseStatus.etc;
    }
  }

  bool isEqualTo(String other) {
    return this.toCode() == other;
  }
}

class HttpsService {
  static final String _defaultUrl = 'https://orre.store/api/user';

  static Uri getUri(String url) {
    return Uri.parse(_defaultUrl + url);
  }

  static Future<http.Response> postRequest(String url, String jsonBody) async {
    print('jsonBody: $jsonBody');
    print('post url: ${getUri(url)}');
    final response = await http.post(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    print('response: ${response.body}');
    return response;
  }

  static Future<http.Response> getRequest(String url) async {
    print('get url: ${getUri(url)}');
    final response = await http.get(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
}
