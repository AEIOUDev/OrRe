import 'package:equatable/equatable.dart';
import 'package:orre/services/debug.services.dart';

class StoreWaitingRequest extends Equatable {
  final String status;
  final StoreWaitingRequestDetail token;

  StoreWaitingRequest({
    required this.status,
    required this.token,
  });

  factory StoreWaitingRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingRequest.nullValue();
    }

    final jsonStatus = json['status'];
    printd("jsonStatus: $jsonStatus");
    final status = jsonStatus ?? '1101';
    printd("status: $status");

    final jsonToken = json['token'];
    printd("jsonToken: $jsonToken");
    final token = StoreWaitingRequestDetail.fromJson(jsonToken);
    printd("token: $token");

    return StoreWaitingRequest(
      status: json['status'] ?? '1101',
      token: StoreWaitingRequestDetail.fromJson(json['token']),
    );
  }

  factory StoreWaitingRequest.nullValue() {
    return StoreWaitingRequest(
      status: '1101',
      token: StoreWaitingRequestDetail(
        storeCode: -1,
        waiting: -1,
        status: -1,
        phoneNumber: '',
        personNumber: -1,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token.toJson(),
    };
  }

  // == 연산자 오버라이드
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StoreWaitingRequest &&
        other.status == status &&
        other.token == token;
  }

  @override
  List<Object?> get props => [status, token];
}

class StoreWaitingRequestDetail extends Equatable {
  final int storeCode;
  final int waiting;
  final int status;
  final int personNumber;
  final String phoneNumber;

  StoreWaitingRequestDetail({
    required this.storeCode,
    required this.waiting,
    required this.status,
    required this.personNumber,
    required this.phoneNumber,
  });

  factory StoreWaitingRequestDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingRequestDetail(
        storeCode: -1,
        waiting: -1,
        status: -1,
        personNumber: -1,
        phoneNumber: '',
      );
    }

    return StoreWaitingRequestDetail(
      storeCode: json['storeCode'] ?? 0,
      waiting: json['waiting'] ?? -1,
      status: json['status'] ?? -1,
      personNumber: json['personNumber'] ?? -1,
      phoneNumber: json['userPhoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'waiting': waiting,
      'status': status,
      'userPhoneNumber': phoneNumber,
      'personNumber': personNumber,
    };
  }

  @override
  List<Object?> get props =>
      [storeCode, waiting, status, personNumber, phoneNumber];
}
