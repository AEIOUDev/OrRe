// 정해진 URL로 입력을 받았는 지 확인하는 함수
import 'debug_services.dart';

Future<String?> checkUrl(String url) async {
  if (url.contains('https://orre.be/reservation/') ||
      url.contains('https://orre.shop/reservation/') ||
      url.contains('http://orre.be/reservation/') ||
      url.contains('http://orre.shop/reservation/')) {
    printd('URL: $url');
    // reservation 뒤의 숫자(자릿수 상관 없음)를 추출하되, 다른 그 이후의 다른 문자열은 무시
    final storeCode = int.tryParse(
        url.substring(url.indexOf('reservation/') + 12, url.length));

    // storeCode를 문자열로 변환하여 반환
    return storeCode.toString();
  } else {
    printd('오리가 서비스하는 URL이 아닙니다.');
    return null;
  }
}
