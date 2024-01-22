import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdState {
  // Future<InitializationStatus> initialization;
  InterstitialAd? interstitialAd;
  // int interstitialAdCounter = 0;

  // AdState(this.initialization) {
  //   this.initialization = initialization;
  //   // Purchases.addPurchaserInfoUpdateListener(
  //   //     (purchaserInfo) => {updatePurchaseStatus()});
  //   // checkIsAdFreeversion();
  // }

  bool isAdFreeVersion = false;

  // Future updatePurchaseStatus() async {
  //   final purchaserInfo = await Purchases.getPurchaserInfo();
  //   final productName =
  //       Platform.isAndroid ? "free_ad_version" : "wowtc_ad_free_version";

  //   if (purchaserInfo.allPurchasedProductIdentifiers.length > 0 &&
  //       purchaserInfo.allPurchasedProductIdentifiers[0] == productName) {
  //     final prefs = await SharedPreferences.getInstance();
  //     prefs.setBool('isAdFreeVersion', true);
  //     isAdFreeVersion = true;
  //     notifyListeners();
  //   }
  // }

  // checkIsAdFreeversion() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool? isAdFree = prefs.getBool("isAdFreeVersion");
  //   if (isAdFree != null && isAdFree == true) {
  //     isAdFreeVersion = true;
  //     notifyListeners();
  //   }
  // }

  // void changeToAdFreeVersion() {
  //   isAdFreeVersion = true;
  //   notifyListeners();
  // }

  static String? get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-8156706115088392/4369191164';

  static String? get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' //ca-app-pub-9790240351769341/5512643521
      : 'ca-app-pub-8156706115088392/4643068037';

  static final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            this.interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAd!.dispose();
            createInterstitialAd();
          },
        ));
  }
}
