import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/debug_services.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_request_state_notifier.dart';
import 'package:orre/provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
import 'package:orre/provider/waiting_usercall_time_list_state_notifier.dart';
import 'package:orre/services/network/https_services.dart';

import '../../../model/store_service_log_model.dart';

final serviceLogProvider =
    StateNotifierProvider<ServiceLogStateNotifier, ServiceLogResponse>((ref) {
  return ServiceLogStateNotifier(ref);
});

class ServiceLogStateNotifier extends StateNotifier<ServiceLogResponse> {
  late Ref ref;
  ServiceLogStateNotifier(this.ref)
      : super(ServiceLogResponse(status: '', userLogs: []));

  Future<ServiceLogResponse> fetchStoreServiceLog(
      String userPhoneNumber) async {
    try {
      // printd("fetchStoreServiceLog");
      // printd("userPhoneNumber: $userPhoneNumber");

      final body = {
        'userPhoneNumber': userPhoneNumber,
      };

      final jsonBody = json.encode(body);
      final response = await HttpsService.postRequest(
          dotenv.get('ORRE_HTTPS_ENDPOINT_STORESERVICELOG'), jsonBody);

      if (response.statusCode == 200) {
        printd("Log is fetched successfully!!!!!!!!!!!!!");
        final jsonBody = json.decode(utf8.decode(response.bodyBytes));
        // printd('jsonBody: $jsonBody');
        // 로그가 없을 때
        if (jsonBody['status'] == APIResponseStatus.serviceLogEmpty.toCode()) {
          state = ServiceLogResponse(
              status: APIResponseStatus.serviceLogEmpty.toCode(), userLogs: []);
          return state;
        }
        // 해당하는 전화번호가 없을 때
        else if (jsonBody['status'] ==
            APIResponseStatus.serviceLogPhoneNumberFailure.toCode()) {
          state = ServiceLogResponse(
              status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
              userLogs: []);
          printd("해당하는 전화번호가 없음");
          return state;
        }
        // 로그가 있을 때
        else {
          printd("로그가 있음");
          final result = ServiceLogResponse.fromJson(jsonBody);
          state = result;
          // printd("state: $state");
          printd("callTime = ${result.userLogs.last.calledTimeOut}");

          return result;
        }
      } else {
        printd("Log is not fetched!!!!!!!!!!!!!");
        state = ServiceLogResponse(
            status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
            userLogs: []);
        throw Exception('Failed to fetch Service Log');
      }
    } catch (error) {
      printd("Log Fetch Error : $error");
      state = ServiceLogResponse(
          status: APIResponseStatus.serviceLogPhoneNumberFailure.toCode(),
          userLogs: []);
      throw Exception('Failed to fetch Service Log');
    }
  }

  void reconnectWebsocketProvider(UserLogs lastUserLog) {
    printd("reconnectWebsocketProvider");
    ref.read(waitingStatus.notifier).setWaitingStatus(lastUserLog.status);

    if (lastUserLog.status == StoreWaitingStatus.WAITING) {
      printd("현재 웨이팅 중! : ${lastUserLog.status}");
      // 현재 웨이팅 중이었다면

      // waitingCancel 재구독
      printd("이전 웨이팅 관련 구독 해제");
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();

      printd("웨이팅 취소 구독 시작");
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingCall 재구독
      printd("유저 호출 구독 해제");
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();

      printd("유저 호출 구독 시작");
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .subscribeToUserCall(lastUserLog.storeCode, lastUserLog.waiting);

      // serviceLog를 기반으로 waiting state를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
    } else if (lastUserLog.status == StoreWaitingStatus.CALLED) {
      // 웨이팅 중인데 호출되었다면
      printd("현재 호출 중! : ${lastUserLog.status}");

      // waitingCancel 재구독
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .subscribeToStoreWaitingCancelRequest(
              lastUserLog.storeCode, lastUserLog.userPhoneNumber.toString());

      // waitingTimer 재설정
      printd("유저 호출 시간 재설정");
      // printd("lastUserLog.calledTimeOut: ${lastUserLog.calledTimeOut}");
      final userCallTime = lastUserLog.calledTimeOut ?? DateTime.now();
      ref
          .read(waitingUserCallTimeListProvider.notifier)
          .setUserCallTime(userCallTime);

      // serviceLog를 기반으로 waiting state 및 UserCall를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
      ref
          .read(storeWaitingUserCallNotifierProvider.notifier)
          .repairUserCallStateByServiceLog(lastUserLog);
    } else if (lastUserLog.status == StoreWaitingStatus.USER_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.STORE_CANCELED ||
        lastUserLog.status == StoreWaitingStatus.ENTERD ||
        lastUserLog.status == StoreWaitingStatus.STORE_CLOSED) {
      // user나 store가 이미 취소했거나 입장했다면
      printd("취소 됨! : ${lastUserLog.status}");

      // 모든 웨이팅 관련 Provider 초기화
      // waitingCancel 삭제
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .clearWaitingRequestList();
      // waitingCall 삭제
      ref.read(storeWaitingUserCallNotifierProvider.notifier).unSubscribe();

      // serviceLog를 기반으로 waiting state를 재구성
      ref
          .read(storeWaitingRequestNotifierProvider.notifier)
          .repairStateByServiceLog(lastUserLog);
    }
  }
}
