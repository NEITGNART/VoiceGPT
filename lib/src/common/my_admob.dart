import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyBannerAd extends StatefulWidget {
  final String adUnitId;

  const MyBannerAd({super.key, required this.adUnitId});

  @override
  _MyBannerAdState createState() => _MyBannerAdState();
}

class _MyBannerAdState extends State<MyBannerAd> {
  BannerAd? _bannerAd;
  bool _showBanner =
      false; // Variable to determine whether to show or hide the banner

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _showBanner = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showBanner && _bannerAd != null
        ? SafeArea(
            child: Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          )
        : const SizedBox(); // Return SizedBox if _showBanner is false or _bannerAd is null
  }
}
