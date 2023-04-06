// ignore_for_file: non_constant_identifier_names

import 'package:google_mobile_ads/google_mobile_ads.dart';

String BASE_URL = 'https://api.openai.com/v1/';
// Production
String ANDROID_INTERSTITIAL_ADD_ID = 'ca-app-pub-9169867486567833/2257550917';
String ANDROID_BANNER_ADD_ID = 'ca-app-pub-9169867486567833/4883714258';

// Production
String IOS_INTERSTITIAL_ADD_ID = 'ca-app-pub-1309254053883418/7015706546';
String IOS_BANNER_ADD_ID = 'ca-app-pub-1309254053883418/2102291210';

// Test
// String IOS_BANNER_ADD_ID = 'ca-app-pub-3940256099942544/6300978111';
// String IOS_INTERSTITIAL_ADD_ID = 'ca-app-pub-3940256099942544/1033173712';

String IOS_BANNER_FAQ_ID = 'ca-app-pub-1309254053883418/9191798384';
String IOS_BANNER_SETTING_ID = 'ca-app-pub-1309254053883418/1540291654';
String IOS_BANNER_LanguageID = 'ca-app-pub-1309254053883418/2434818344';
String IOS_BANNER_VoiceId = 'ca-app-pub-1309254053883418/1161303111';

String Android_Banner_VoiceId = 'ca-app-pub-9169867486567833/9944469242';
String Android_Banner_LanguageID = 'ca-app-pub-9169867486567833/9038581684';
String Android_Banner_FAQ_ID = 'ca-app-pub-9169867486567833/4320607472';
String Android_Banner_SETTING_ID = 'ca-app-pub-9169867486567833/6412418348';
String Android_Reward_ID = 'ca-app-pub-9169867486567833/8847009996';
String IOS_Reward_ID = 'ca-app-pub-1309254053883418/7470209523';

BannerAd createBannerAds(String Id) {
  return BannerAd(
    adUnitId: Id,
    size: AdSize.fullBanner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );
}
