import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/model/menu_info_model.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:orre/model/user_info_model.dart';
import 'package:orre/provider/store_info_state_notifier.dart';
import '../presenter/main_screen.dart';
import '../provider/my_waiting_state_notifier.dart';
import '../provider/store_location_list_state_notifier.dart';
import '../provider/store_waiting_request_state_notifier.dart';

// NFC 스캔 가능 상태를 관리하는 StateProvider
final nfcScanAvailableProvider = StateProvider<bool>((ref) => true);

// NFC 스캔 결과 메시지를 관리하는 StateProvider
final nfcScanMessageProvider =
    StateProvider<String>((ref) => 'NFC 태그에 가까이 하세요.');

// NFC 스캔을 시작하는 함수
Future<void> startNFCScan(WidgetRef ref) async {
  // NFC 스캔 가능 상태를 확인
  if (!ref.read(nfcScanAvailableProvider.notifier).state) return;

  // NFC 스캔 가능 상태를 false로 설정하여 중복 스캔 방지
  ref.read(nfcScanAvailableProvider.notifier).state = false;

  bool isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) {
    ref.read(nfcScanMessageProvider.notifier).state = 'CANCLE';
    // 스캔 가능 상태를 다시 true로 설정
    Timer(Duration(seconds: 4),
        () => ref.read(nfcScanAvailableProvider.notifier).state = true);
    return;
  }

  NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        final records = ndef.cachedMessage?.records ?? [];
        for (final record in records) {
          final uriRecord = String.fromCharCodes(record.type) == 'U'
              ? Uri.decodeFull(String.fromCharCodes(record.payload.skip(1)))
              : null;

          if (uriRecord != null) {
            ref.read(nfcScanMessageProvider.notifier).state =
                uriSwitcher(uriRecord, ref);
            break;
          }
        }
      } else {
        ref.read(nfcScanMessageProvider.notifier).state = '지원하지 않는 태그입니다.';
      }

      if (Platform.isIOS) {
        NfcManager.instance.stopSession();
      }
    },
    onError: (e) async {
      ref.read(nfcScanMessageProvider.notifier).state = 'NFC 스캔 중 에러 발생: $e';
    },
  );

  // 4초 후에 스캔 가능 상태를 다시 true로 설정
  Timer(Duration(seconds: 4),
      () => ref.read(nfcScanAvailableProvider.notifier).state = true);
}

String uriSwitcher(String uri, WidgetRef ref) {
  // URI에서 마지막 '/' 이후의 문자열(예: 001)을 추출합니다.
  final uriParts = uri.split('/');
  final identifier = uriParts.last;

  if (uri.contains('reservation')) {
    // 'reservation'을 포함하는 경우, 'r'을 붙여 반환합니다.
    ref.read(selectedIndexProvider.notifier).state =
        pageIndex.orderScreen.index;
    return 'r$identifier';
  } else if (uri.contains('waiting')) {
    ref.read(selectedIndexProvider.notifier).state =
        pageIndex.waitingScreen.index;
    // 'waiting'을 포함하는 경우, 'w'을 붙여 반환합니다.
    print(identifier);
    ref.read(storeWaitingListProvider.notifier).sendStoreCode(identifier);
    ref.read(storeInfoProvider.notifier).sendStoreCode(identifier);
    ref.read(myWaitingsProvider.notifier).requestWaiting(
        identifier,
        UserSimpleInfo(
            name: "testName", phoneNumber: "01092566504", numberOfUs: 4));
    return 'w$identifier';
  } else {
    // 둘 다 아닌 경우, 입력된 uri를 그대로 반환합니다.
    // 혹은 이 경우에 대한 다른 처리를 할 수도 있습니다.
    return uri;
  }
}
