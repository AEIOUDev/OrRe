import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/menu_info_model.dart';
import '../model/store_info_model.dart';

final storeListStreamProvider =
    StreamProvider.family<List<StoreInfo>, LocationInfo>((ref, userLocation) {
  // final Uri websocketUri = Uri.parse('ws://192.168.1.214:8080/ws');
  final Uri websocketUri = Uri.parse('ws://echo.websocket.org');
  final channel = WebSocketChannel.connect(websocketUri);

  final latitude = userLocation.latitude;
  final longitude = userLocation.longitude;
  print('storeListStreamProvier_latitude : $latitude');
  print('storeListStreamProvier_longtitude : $longitude');

  // final jsonData = jsonEncode(testCase);
  final jsonData = singleTestCase.toJson();

  channel.sink.add(jsonData.toString());

  channel.stream.listen((data) {
    print('수신 데이터: $data');
    final JsonData = data.toJson();
    print('수신 데이터: $JsonData');
    // channel.sink.add(jsonData);
    // WaitingTime 정보 요청 및 처리
    if (data.contains('CONNECTED')) {
      print('Connected to the server.');
      // 연결 성공 후, /topic/waitingTimeInfo 주제에 구독
      channel.sink.add(
          'SUBSCRIBE\nid:sub-1\ndestination:/topic/waitingTimeInfo\n\n\x00');
      // 연결 성공 후 즉시 /waitingTimeInfoRequest 요청을 보내야 함
      channel.sink.add('SEND\ndestination:/app/waitingTimeInfoRequest\n\n\x00');
    } else if (data.contains('MESSAGE')) {
      //topic/waitingTimeInfo로부터 메시지 수신 확인
      if (data.contains('destination:/topic/waitingTimeInfo')) {
        final payloadStart = data.indexOf('\n\n') + 2;
        var payload = data.substring(payloadStart).trim();
        payload = payload.replaceAll('\x00', '');
        try {
          // 수신된 메시지 처리 (예: JSON 파싱)
          final messageData = json.decode(payload);
          // JSON 문자열을 Waitingtime 객체로 변환
          final waitingTime = StoreWaitingInfo.fromJson(messageData);
          // 객체 필드에 접근하여 출력
          print('Server Code 2: ${waitingTime.storeInfo.storeCode}');
          print('nowEnteringNumbers: ${waitingTime.nowEnteringNumbers}');
          print('Predict Waiting Time: ${waitingTime.estimatedWaitingTime}');
        } catch (e) {
          print('Error parsing JSON: $e');
          print('Original payload: $payload');
        }
      }
    }
    // channel.sink.add(jsonData);
  });

  return channel.stream.map((data) {
    print(data);
    final jsonData = jsonDecode(data);
    print(jsonData);
    return [
      StoreInfo(
        storeCode: "001",
        storeName: "test",
        storeInfoVersion: 1,
        locationInfo: LocationInfo(
            address: "address",
            latitude: 32,
            locationName: "name",
            longitude: 127),
        menuList: [
          MenuInfo(
              menuCode: "A01",
              menuName: "라면",
              menuDescription: "달콤짭짤",
              menuPrice: 2000,
              menuImage: Image.asset("test"),
              isRecommended: true)
        ],
      )
    ];
  });
});

final singleTestCase = StoreInfo(
  storeCode: "001",
  storeName: "test",
  storeInfoVersion: 1,
  locationInfo: LocationInfo(
      address: "address", latitude: 32, locationName: "name", longitude: 127),
  menuList: [
    MenuInfo(
        menuCode: "A01",
        menuName: "라면",
        menuDescription: "달콤짭짤",
        menuPrice: 2000,
        menuImage: Image.asset("test"),
        isRecommended: true)
  ],
);

final testCase = [
  StoreInfo(
    storeCode: "001",
    storeName: "test",
    storeInfoVersion: 1,
    locationInfo: LocationInfo(
        address: "address", latitude: 32, locationName: "name", longitude: 127),
    menuList: [
      MenuInfo(
          menuCode: "A01",
          menuName: "라면",
          menuDescription: "달콤짭짤",
          menuPrice: 2000,
          menuImage: Image.asset("test"),
          isRecommended: true)
    ],
  ),
  StoreInfo(
    storeCode: "002",
    storeName: "메뉴",
    storeInfoVersion: 1,
    locationInfo: LocationInfo(
      address: "주소",
      latitude: 33,
      locationName: "다양한 메뉴 위치",
      longitude: 128,
    ),
    menuList: [
      MenuInfo(
        menuCode: "B01",
        menuName: "피자",
        menuDescription: "고소한 치즈와 풍미 가득한 토핑",
        menuPrice: 15000,
        menuImage: Image.asset("test"),
        isRecommended: true,
      ),
      MenuInfo(
        menuCode: "B02",
        menuName: "햄버거",
        menuDescription: "육즙 가득한 패티와 신선한 야채",
        menuPrice: 8000,
        menuImage: Image.asset("hamburger.jpg"),
        isRecommended: false,
      ),
      MenuInfo(
        menuCode: "B03",
        menuName: "샐러드",
        menuDescription: "건강하고 맛있는 다양한 채소",
        menuPrice: 12000,
        menuImage: Image.asset("salad.jpg"),
        isRecommended: true,
      ),
    ],
  ),
  StoreInfo(
    storeCode: "003",
    storeName: "옵션 선택 가능",
    storeInfoVersion: 1,
    locationInfo: LocationInfo(
      address: "주소",
      latitude: 34,
      locationName: "위치",
      longitude: 129,
    ),
    menuList: [
      MenuInfo(
        menuCode: "C01",
        menuName: "커피",
        menuDescription: "향긋한 커피",
        menuPrice: 3000,
        menuImage: Image.asset("coffee.jpg"),
        isRecommended: true,
      ),
    ],
  ),
  StoreInfo(
      storeCode: "004",
      storeName: "Porshe",
      storeInfoVersion: 1,
      locationInfo: LocationInfo(
        address: "주소",
        latitude: 35,
        locationName: "위치",
        longitude: 130,
      ),
      menuList: [
        MenuInfo(
          menuCode: "D01",
          menuName: "밥류",
          menuDescription: "든든한 밥류 메뉴",
          menuPrice: 7000,
          menuImage: Image.asset("rice.jpg"),
          isRecommended: false,
        ),
        MenuInfo(
          menuCode: "D02",
          menuName: "국",
          menuDescription: "따뜻하고 맛있는 국 메뉴",
          menuPrice: 5000,
          menuImage: Image.asset("soup.jpg"),
          isRecommended: true,
        ),
        MenuInfo(
          menuCode: "D03",
          menuName: "면류",
          menuDescription: "시원하고 쫄깃한 면류 메뉴",
          menuPrice: 6000,
          menuImage: Image.asset("noodles.jpg"),
          isRecommended: false,
        ),
      ])
];
