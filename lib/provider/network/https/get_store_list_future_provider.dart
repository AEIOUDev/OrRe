import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:orre/model/store_list_model.dart';

class storeListParameters {
  String sortType;
  double latitude;
  double longitude;
  storeListParameters(
      {required this.sortType,
      required this.latitude,
      required this.longitude});
}

final storeListProvider =
    FutureProvider.family<List<StoreLocationInfo>, storeListParameters>(
        (ref, params) async {
  print("${params.sortType}ListProvider");

  String sortType = params.sortType;
  double latitude = params.latitude;
  double longitude = params.longitude;
  print("latitude: $latitude, longitude: $longitude");

  final baseUrl = '/storeList/$sortType';
  final body = {
    'latitude': latitude,
    'longitude': longitude,
  };
  final url = '$baseUrl?latitude=$latitude&longitude=$longitude';

  final jsonBody = json.encode(body);
  print('jsonBody: $jsonBody');

  final response = await HttpsService.getRequest(url);

  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

  if (response.statusCode == 200) {
    final jsonBody = json.decode(utf8.decode(response.bodyBytes));
    print('jsonBody: $jsonBody');
    final result =
        (jsonBody as List).map((e) => StoreLocationInfo.fromJson(e)).toList();
    print('result: $result');
    return result;
  } else {
    print('response.statusCode: ${response.statusCode}');
    return [];
    throw Exception('Failed to fetch store info');
  }
});
