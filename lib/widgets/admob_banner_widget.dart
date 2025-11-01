import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // Uncomment when ready to use AdMob

/// AdMob Banner Widget
/// 
/// This widget is a placeholder for Google AdMob banner ads.
/// To enable AdMob:
/// 
/// 1. Uncomment the import statement above
/// 2. Replace the placeholder with actual AdMob code:
/// 
/// ```dart
/// final BannerAd? bannerAd;
/// 
/// @override
/// void initState() {
///   super.initState();
///   bannerAd = BannerAd(
///     adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
///     size: AdSize.banner,
///     request: const AdRequest(),
///     listener: BannerAdListener(
///       onAdLoaded: (_) => setState(() {}),
///       onAdFailedToLoad: (ad, error) {
///         ad.dispose();
///       },
///     ),
///   )..load();
/// }
/// 
/// @override
/// void dispose() {
///   bannerAd?.dispose();
///   super.dispose();
/// }
/// 
/// @override
/// Widget build(BuildContext context) {
///   if (bannerAd == null) return const SizedBox();
///   return SizedBox(
///     width: bannerAd!.size.width.toDouble(),
///     height: bannerAd!.size.height.toDouble(),
///     child: AdWidget(ad: bannerAd!),
///   );
/// }
/// ```

class AdMobBannerWidget extends StatelessWidget {
  const AdMobBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder - Replace with actual AdMob implementation
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          'AdMob Banner Placeholder',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// AdMob Interstitial Helper
/// 
/// Use this class to show interstitial ads at appropriate times.
/// Example usage:
/// 
/// ```dart
/// AdMobInterstitialHelper.showInterstitialAd();
/// ```

class AdMobInterstitialHelper {
  // static InterstitialAd? _interstitialAd;
  
  /// Initialize and load interstitial ad
  /// 
  /// Call this method when you want to prepare an interstitial ad
  /// (e.g., after user completes an action)
  static Future<void> loadInterstitialAd() async {
    // Placeholder implementation
    // Uncomment and implement when ready to use AdMob:
    
    // InterstitialAd.load(
    //   adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _interstitialAd = ad;
    //       _interstitialAd!.setImmersiveMode(true);
    //     },
    //     onAdFailedToLoad: (error) {
    //       _interstitialAd = null;
    //     },
    //   ),
    // );
  }
  
  /// Show interstitial ad if loaded
  /// 
  /// Call this method when you want to display an interstitial ad
  static void showInterstitialAd() {
    // Placeholder implementation
    // Uncomment when ready to use AdMob:
    
    // if (_interstitialAd != null) {
    //   _interstitialAd!.show();
    //   _interstitialAd = null;
    // }
  }
  
  /// Dispose interstitial ad
  static void dispose() {
    // _interstitialAd?.dispose();
    // _interstitialAd = null;
  }
}

