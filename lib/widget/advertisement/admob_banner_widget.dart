import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/admob_services.dart';

class AdmobBannerWidget extends ConsumerStatefulWidget {
  @override
  _AdmobBannerWidgetState createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends ConsumerState<AdmobBannerWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId ?? "",
      size: AdSize.banner,
      request: AdRequest(),
      listener: AdMobService.bannerAdListener,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        height: 100,
        width: 0.95.sw,
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
