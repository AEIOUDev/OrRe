import 'package:equatable/equatable.dart';

class StoreWaitingInfo extends Equatable {
  final int storeCode;
  final List<int> waitingTeamList;
  final List<int> enteringTeamList;
  final int estimatedWaitingTimePerTeam;

  StoreWaitingInfo({
    required this.storeCode,
    required this.waitingTeamList,
    required this.enteringTeamList,
    required this.estimatedWaitingTimePerTeam,
  });

  factory StoreWaitingInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreWaitingInfo(
        storeCode: 0,
        waitingTeamList: [],
        enteringTeamList: [],
        estimatedWaitingTimePerTeam: 0,
      );
    }

    return StoreWaitingInfo(
      storeCode: json['storeCode'] ?? 0,
      waitingTeamList: List<int>.from(json['waitingTeamList'] ?? []),
      enteringTeamList: List<int>.from(json['enteringTeamList'] ?? []),
      estimatedWaitingTimePerTeam: json['estimatedWaitingTimePerTeam'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'waitingTeamList': waitingTeamList,
      'enteringTeamList': enteringTeamList,
      'estimatedWaitingTimePerTeam': estimatedWaitingTimePerTeam,
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        storeCode,
        waitingTeamList,
        enteringTeamList,
        estimatedWaitingTimePerTeam,
      ];
}
