import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:stomp_dart_client/stomp.dart';

final storeInfoTrigger = StateProvider<bool?>((ref) {
  return null;
});

final storeDetailInfoWebsocketProvider =
    StateNotifierProvider<StoreDetailInfoStateNotifier, StoreDetailInfo?>(
        (ref) {
  return StoreDetailInfoStateNotifier();
});

class StoreDetailInfoStateNotifier extends StateNotifier<StoreDetailInfo?> {
  StoreDetailInfoStateNotifier() : super(null) {}
  StompClient? _client;

  Map<dynamic, dynamic> _subscribeStoreInfo = {};
  int storeCodeForRequest = -1;

  void setClient(StompClient client) {
    // Set the client here
    print("StoreDetailInfoStateNotifier setClient");
    _client = client;
  }

  Stream<StoreDetailInfo?> subscribeStoreDetailInfo(int storeCode) {
    print("StoreDetailInfoStateNotifier subscribeStoreDetailInfo : $storeCode");
    if (_client == null) {
      print(
          "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : client is null");
      return Stream.value(null);
    }
    if (_subscribeStoreInfo[storeCode.toString()] == null) {
      _subscribeStoreInfo[storeCode.toString()] = _client?.subscribe(
          destination:
              dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREDETAILINFO_SUBSCRIBE') +
                  storeCode.toString(),
          callback: (frame) {
            if (frame.body != null) {
              var decodedBody = json.decode(frame.body!);
              state = StoreDetailInfo.fromJson(decodedBody);
              print("decodedBody : $decodedBody");
              print("state : ${state?.storeCode}");
            }
          });
    } else {
      print(
          "StoreDetailInfoStateNotifier subscribeStoreDetailInfo : already subscribed");
    }
    return Stream.value(state);
  }

  void sendStoreDetailInfoRequest(int storeCode) {
    print(
        "StoreDetailInfoStateNotifier sendStoreDetailInfoRequest : $storeCode");
    storeCodeForRequest = storeCode;
    _client?.send(
        destination:
            dotenv.get('ORRE_WEBSOCKET_ENDPOINT_STOREDETAILINFO_REQUEST') +
                storeCode.toString(),
        body: json.encode({'storeCode': storeCode}));
  }

  void clearStoreDetailInfo() {
    state = null;
    print("StoreDetailInfoStateNotifier clearStoreDetailInfo");
    _subscribeStoreInfo.forEach((key, value) {
      _subscribeStoreInfo[key](unsubscribeHeaders: <String, String>{});
    });
    _subscribeStoreInfo.clear();
  }
}
