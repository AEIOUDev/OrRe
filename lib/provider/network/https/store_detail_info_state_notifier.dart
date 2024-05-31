import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_info_model.dart';

import '../../../services/network/https_services.dart';

class StoreInfoParams {
  int storeCode;
  int storeTableNumber;

  StoreInfoParams(this.storeCode, this.storeTableNumber);
}

final storeDetailInfoHttpsProvider =
    StateNotifierProvider<StoreDetailInfoNotifier, StoreDetailInfo>((ref) {
  return StoreDetailInfoNotifier();
});

class StoreDetailInfoNotifier extends StateNotifier<StoreDetailInfo> {
  StoreDetailInfoNotifier() : super(StoreDetailInfo.nullValue());

  Future<void> fetchStoreDetailInfo(StoreInfoParams params) async {
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
        print("storeDetailInfoHttpsProvider(json 200): $jsonBody");
        final result = StoreDetailInfo.fromJson(jsonBody);

        state = result;
      } else {
        state = StoreDetailInfo.nullValue();
        throw Exception('Failed to fetch store info');
      }
    } catch (error) {
      state = StoreDetailInfo.nullValue();
      throw Exception('Failed to fetch store info');
    }
  }

  void clearStoreDetailInfo() {
    state = StoreDetailInfo.nullValue();
  }

  bool isCanReserve() {
    // final isRunTime =
    //     isCurrentTimeBetween(state.openingTime, state.closingTime);
    // final isBreakTime =
    //     isCurrentTimeBetween(state.breakStartTime, state.breakEndTime);

    // return isRunTime && !isBreakTime;
    return state.waitingAvailable == 0;
  }
}
