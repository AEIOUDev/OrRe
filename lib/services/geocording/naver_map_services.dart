import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../debug_services.dart';

Future<List<String?>> getAddressFromLatLngNaver(
    double latitude, double longitude, int detail, bool includeArea1) async {
  printd("Naver Map API");
  final String clientId = dotenv.env['NAVER_API_ID']!; // Naver API 클라이언트 ID
  final String clientSecret =
      dotenv.env['NAVER_API_SECRET']!; // Naver API 클라이언트 Secret

  final String url =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc'
      '?request=coordsToaddr&coords=$longitude,$latitude&sourcecrs=epsg:4326&output=json&orders=addr';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-NCP-APIGW-API-KEY-ID": clientId,
        "X-NCP-APIGW-API-KEY": clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // API 응답으로부터 주소 정보를 파싱합니다.
      String address = '';

      // includeArea1 : 광역/기초 자치단체 제외 여부
      // detail : 행정구역 세부 표현 단계 조절
      // 광역/기초 자치단체
      printd("naver_map_services : $responseData");

      // 네이버 API가 지원하는 위치가 아닌 경우 기본값 반환
      if (responseData['status']['code'] == 3) {
        printd("지원범위 밖");
        return ["지원범위 밖", "지원범위 밖"];
      }
      if (detail >= 1 && includeArea1) {
        address +=
            (responseData['results'][0]['region']['area1']['name'] ?? '');
      }
      // 3단계 (일반구, 행정시)
      if (detail >= 2) {
        address +=
            ' ' + (responseData['results'][0]['region']['area2']['name'] ?? '');
      }
      // 4단계(읍면동)
      if (detail >= 3) {
        address +=
            ' ' + (responseData['results'][0]['region']['area3']['name'] ?? '');
      }
      // 5단계(리, 통)
      if (detail >= 4) {
        address +=
            ' ' + (responseData['results'][0]['region']['area4']['name'] ?? '');
      }
      // 6단계인 '반'은 넣지 않았음.

      // 4~5단계만 포함된 String과 전체 주소를 List로 반환
      List<String?> addressList = [];
      String placeName = '';

      if (responseData['results'][0]['land']['name'] == null) {
        placeName += (responseData['results'][0]['region']['area3']['name']);
        placeName += ' ';
        placeName += (responseData['results'][0]['region']['area4']['name']);
      } else {
        placeName = responseData['results'][0]['land']['name'];
      }

      addressList = [placeName.trim(), address.trim()];

      return addressList;
    } else {
      // 요청이 실패했을 경우
      print('Failed to fetch address: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching address: $e');
    return [];
  }
}
