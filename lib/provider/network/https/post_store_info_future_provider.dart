import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:orre/provider/network/https/store_detail_info_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';

Future<StoreDetailInfo> fetchStoreDetailInfo(StoreInfoParams params) async {
  try {
    String storeCode = params.storeCode.toString();
    String storeTableNumber = params.storeTableNumber.toString();
    final body = {
      'storeCode': storeCode,
      'storeTableNumber': storeTableNumber,
    };
    final jsonBody = json.encode(body);
    final response = await HttpsService.postRequest("/storeInfo", jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      print("storeDetailInfoProvider(json 200): $jsonBody");
      final result = StoreDetailInfo.fromJson(jsonBody);

      return result;
    } else {
      throw Exception('Failed to fetch store info');
    }
  } catch (error) {
    throw Exception('Failed to fetch store info');
  }
}

final storeDetailProvider =
    FutureProvider.family<StoreDetailInfo, int>((ref, storeCode) async {
  return fetchStoreDetailInfo(StoreInfoParams(
      storeCode, 0)); // 여기서 fetchStoreDetailInfo는 상세 정보를 가져오는 함수
});
