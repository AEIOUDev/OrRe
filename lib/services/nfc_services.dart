import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../presenter/main/main_screen.dart';
import 'debug.services.dart';

final nfcAvailableProvider = StateProvider<bool>((ref) => false);

// NFC 스캔 가능 상태를 관리하는 StateProvider
final nfcScanAvailableProvider = StateProvider<bool>((ref) => true);

// NFC 스캔 결과 메시지를 관리하는 StateProvider
final nfcScanMessageProvider =
    StateProvider<String>((ref) => '테이블에 부착된 NFC 태그에 가까이 하세요.');

// NFC 스캔을 시작하는 함수
Future<void> startNFCScan(WidgetRef ref, BuildContext context) async {
  printd("NFC 스캔 시작");
  // NFC 스캔 가능 상태를 확인
  if (!ref.read(nfcScanAvailableProvider.notifier).state) return;

  printd("NFC 스캔 가능 상태 확인 완료");
  // NFC 스캔 가능 상태를 false로 설정하여 중복 스캔 방지
  ref.read(nfcScanAvailableProvider.notifier).state = false;

  // NFC 사용 가능 여부를 확인
  bool isAvailable = await NfcManager.instance.isAvailable();
  printd("NFC 사용 가능 여부: $isAvailable");
  if (!isAvailable) {
    ref.read(nfcScanMessageProvider.notifier).state = 'CANCLE';
    // 스캔 가능 상태를 다시 true로 설정
    Timer(Duration(seconds: 4),
        () => ref.read(nfcScanAvailableProvider.notifier).state = true);
    return;
  }
  printd("NFC 사용 가능 여부 확인 완료");
  NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      printd("NFC 태그 발견: $tag");
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        final records = ndef.cachedMessage?.records ?? [];
        for (final record in records) {
          final uriRecord = String.fromCharCodes(record.type) == 'U'
              ? Uri.decodeFull(String.fromCharCodes(record.payload.skip(1)))
              : null;

          if (uriRecord != null) {
            ref.read(nfcScanMessageProvider.notifier).state =
                uriSwitcher(uriRecord, ref, context);
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

String uriSwitcher(String uri, WidgetRef ref, BuildContext context) {
  // URI에서 마지막 '/' 이후의 문자열(예: 001)을 추출합니다.
  final uriParts = uri.split('/');
  final identifier = uriParts.last;
  print("last uriParts: $identifier");

  if (uri.contains('reservation')) {
    // 'reservation'을 포함하는 경우, 'r'을 붙여 반환합니다.
    ref.read(selectedIndexProvider.notifier).state =
        pageIndex.orderScreen.index;
    return 'r$identifier';
  } else if (uri.contains('waiting')) {
    ref.read(selectedIndexProvider.notifier).state =
        pageIndex.waitingScreen.index;
    // 'waiting'을 포함하는 경우, 'w'을 붙여 반환합니다.

    context.push("/storeinfo/${identifier}");
    // ref.read(storeWaitingListProvider.notifier).sendStoreCode(identifier);
    // ref.read(myWaitingsProvider.notifier).requestWaiting(
    //     identifier,
    //     UserSimpleInfo(
    //         name: "testName", phoneNumber: "01092566504", numberOfUs: 4));
    return 'w$identifier';
  } else {
    // 둘 다 아닌 경우, 입력된 uri를 그대로 반환합니다.
    // 혹은 이 경우에 대한 다른 처리를 할 수도 있습니다.
    return uri;
  }
}

void readNfcTag() {
  NfcManager.instance.startSession(onDiscovered: (NfcTag badge) async {
    var ndef = Ndef.from(badge);

    if (ndef != null && ndef.cachedMessage != null) {
      String tempRecord = "";
      for (var record in ndef.cachedMessage!.records) {
        tempRecord =
            "$tempRecord ${String.fromCharCodes(record.payload.sublist(record.payload[0] + 1))}";
      }

      printd("NFC 태그 발견: $tempRecord");
    } else {
      // Show a snackbar for example
    }

    NfcManager.instance.stopSession();
  });
}
