import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../services/debug_services.dart';
import '../../services/store_service.dart';

final scanDataProvider = StateProvider<Barcode?>((ref) => null);

class QRScannerScreen extends ConsumerStatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    printd("QR 스캔 화면 초기화");
  }

  @override
  Widget build(BuildContext context) {
    printd("QR 스캔 화면 빌드 중");
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.25.sh),
        child: StaticAppBarWidget(
          title: 'QR 스캔',
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xFFFFBF52),
        ),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white),
              onPressed: () {
                controller?.toggleFlash();
              },
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: Icon(Icons.cameraswitch, color: Colors.white),
              onPressed: () {
                controller?.flipCamera();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      printd("QR 스캔 결과: ${scanData.code}");

      if (scanData.code != null) {
        String? storeCode = await checkUrl(scanData.code!);

        if (storeCode != null) {
          controller.stopCamera();
          context.pop();
          context.push("/storeinfo/$storeCode");
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void flipCamera() {
    controller?.flipCamera();
  }

  void toggleFlash() {
    controller?.toggleFlash();
  }
}
