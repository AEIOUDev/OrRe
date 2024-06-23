import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid)
      return 'ca-app-pub-1350885147638403/2621312687';
    else if (Platform.isIOS)
      return 'ca-app-pub-1350885147638403/6463520624';
    else
      return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (Ad ad) => print('Ad loaded: $ad'),
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load: $error');
    },
    onAdOpened: (Ad ad) => print('Ad opened: $ad'),
    onAdClosed: (Ad ad) => print('Ad closed: $ad'),
    onAdImpression: (Ad ad) => print('Ad impression: $ad'),
    onAdClicked: (Ad ad) => print('Ad clicked: $ad'),
  );
}
