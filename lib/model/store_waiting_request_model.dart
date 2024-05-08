class StoreWaitingRequest {
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

    return StoreWaitingRequest(
      status: json['status'] ?? '1101',
      token: StoreWaitingRequestDetail.fromJson(json['token']),
    );
  }

  factory StoreWaitingRequest.nullValue() {
    return StoreWaitingRequest(
      status: '1101',
      token: StoreWaitingRequestDetail(
        storeCode: 0,
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
}

class StoreWaitingRequestDetail {
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
        storeCode: 0,
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
}
