import 'dart:math';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:admob_flutter/admob_flutter.dart' as admob_flutter;

import 'package:MyNews/shared/keys.dart';

// Admob Helper class
class AdMobHelper {
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
