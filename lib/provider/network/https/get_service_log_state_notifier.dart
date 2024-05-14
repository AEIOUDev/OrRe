import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/menu_info_model.dart';
import 'package:orre/services/network/https_services.dart';

class ServiceLogResponse {
  final String status;
  final List<UserLogs> userLogs;

  ServiceLogResponse({
    required this.status,
    required this.userLogs,
  });

  ServiceLogResponse copyWith({
    String? status,
    List<UserLogs>? userLogs,
  }) {
    return ServiceLogResponse(
      status: status ?? this.status,
      userLogs: userLogs ?? this.userLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'userLogs': userLogs.map((log) => log.toJson()).toList(),
    };
  }

  static ServiceLogResponse fromJson(Map<String, dynamic> json) {
    return ServiceLogResponse(
      status: json['status'],
      userLogs: List<UserLogs>.from(
          json['userLogs'].map((log) => UserLogs.fromJson(log))),
    );
  }
}

class UserLogs {
  final String userPhoneNumber;
  final int historyNum;
  final String status;
  final DateTime? makeWaitingTime;
  final int storeCode;
  final DateTime? statusChangeTime;
  final int paidMoney;
  final List<MenuInfo> orderedMenu;

  UserLogs({
    required this.userPhoneNumber,
    required this.historyNum,
    required this.status,
    required this.makeWaitingTime,
    required this.storeCode,
    required this.statusChangeTime,
    required this.paidMoney,
    required this.orderedMenu,
  });

  Map<String, dynamic> toJson() {
    return {
      'userPhoneNumber': userPhoneNumber,
      'historyNum': historyNum,
      'status': status,
      'makeWaitingTime': makeWaitingTime.toString(),
      'storeCode': storeCode,
      'statusChangeTime': statusChangeTime.toString(),
      'paidMoney': paidMoney,
      'orderedMenu': orderedMenu.map((menu) => menu.toJson()).toList(),
    };
  }

  static UserLogs fromJson(Map<String, dynamic> json) {
    return UserLogs(
      userPhoneNumber: json['userPhoneNumber'],
      historyNum: json['historyNum'],
      status: json['status'],
      makeWaitingTime: DateTime.parse(json['makeWaitingTime']),
      storeCode: json['storeCode'],
      statusChangeTime: DateTime.parse(json['statusChangeTime']),
      paidMoney: json['paidMoney'],
      orderedMenu: List<MenuInfo>.from(
          json['orderedMenu'].map((menu) => MenuInfo.fromJson(menu))),
    );
  }
}

final serviceLogProvider =
    StateNotifierProvider<ServiceLogStateNotifier, ServiceLogResponse>((ref) {
  return ServiceLogStateNotifier();
});

class ServiceLogStateNotifier extends StateNotifier<ServiceLogResponse> {
  ServiceLogStateNotifier()
      : super(ServiceLogResponse(status: '', userLogs: []));

  Future<ServiceLogResponse> fetchStoreServiceLog(
      String userPhoneNumber) async {
    try {
      print("fetchStoreServiceLog");
      print("userPhoneNumber: $userPhoneNumber");

      final baseUrl = '/log';

      final url = '$baseUrl?userPhoneNumber=$userPhoneNumber';

      final response = await HttpsService.getRequest(url);

      if (response.statusCode == 200) {
        print("Log is fetched successfully!!!!!!!!!!!!!");
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        print('jsonBody: $jsonBody');
        final result = ServiceLogResponse.fromJson(jsonBody);
        state = result;
        print("state: $state");
        return result;
      } else {
        print("Log is not fetched!!!!!!!!!!!!!");
        state = ServiceLogResponse(status: '', userLogs: []);
        throw Exception('Failed to fetch Service Log');
      }
    } catch (error) {
      print("Log Fetch Error : $error");
      state = ServiceLogResponse(status: '', userLogs: []);
      throw Exception('Failed to fetch Service Log');
    }
  }
}
