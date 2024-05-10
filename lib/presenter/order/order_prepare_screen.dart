import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../services/nfc_services.dart';

class OrderPrepareScreen extends ConsumerStatefulWidget {
  @override
  _OrderPrepareScreenState createState() => _OrderPrepareScreenState();
}

class _OrderPrepareScreenState extends ConsumerState<OrderPrepareScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) => startNFCScan(ref));
  // }

  @override
  Widget build(BuildContext context) {
    final _message = ref.watch(nfcScanMessageProvider);

    return Scaffold(
      appBar: AppBar(title: TextWidget('Order Prepare')),
      body: Center(child: TextWidget(_message)),
    );
  }
}
