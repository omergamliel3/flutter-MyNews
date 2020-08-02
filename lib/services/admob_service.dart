import 'dart:math';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:admob_flutter/admob_flutter.dart' as admob_flutter;

// Admob Helper class
class AdMobHelper {
  // admob app id
  static const String appId = 'ca-app-pub-5868916330908541~1053435177';

  // native ad id
  static const String nativeAdID = 'ca-app-pub-5868916330908541/9530351684';
  // banner ad id
  static const String bannerAdID = 'ca-app-pub-5868916330908541/9465104203';
  // interstitial ad id
  static const String interstitialAdID =
      'ca-app-pub-5868916330908541/7399012360';
  // mobile ad targeting information
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'Insurance',
      'Online education',
      'Marketing and Advertising',
      'Legal averaging',
      'Internet & telecom',
      'Online banking'
    ],
  );

  static InterstitialAd interstitialAd;

  /// initialise admob services instance
  static void initialiseAdMob() {
    FirebaseAdMob.instance.initialize(appId: appId);
    admob_flutter.Admob.initialize(appId);
    createInterstitialAd();
  }

  /// create Interstitial Ad
  static createInterstitialAd() {
    interstitialAd = InterstitialAd(
      adUnitId: interstitialAdID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.closed ||
            event == MobileAdEvent.failedToLoad) {
          // reset interstitialAd when closed or failed to load
          createInterstitialAd();
        }
      },
    );
    // load the ad
    interstitialAd..load();
  }

  // randomize show interstitial ad to reduce showing to much ads
  static void showRandomInterstitialAd() async {
    // dont show ad if not loaded
    if (!await interstitialAd.isLoaded()) return;

    Random random = new Random();
    int randNum = random.nextInt(100);

    if (randNum > 40) {
      interstitialAd..show();
    }
  }
}
