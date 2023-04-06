import 'dart:io' show Platform;

import '../utils/constants.dart';

class AdMobService {
  static String? get mainPageBannerId {
    if (Platform.isAndroid) {
      return ANDROID_BANNER_ADD_ID;
    } else if (Platform.isIOS) {
      return IOS_BANNER_ADD_ID;
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return ANDROID_INTERSTITIAL_ADD_ID;
    } else if (Platform.isIOS) {
      return IOS_INTERSTITIAL_ADD_ID;
    }
    return null;
  }

  static String? get languageBannerId {
    if (Platform.isAndroid) {
      return Android_Banner_LanguageID;
    } else if (Platform.isIOS) {
      return IOS_BANNER_LanguageID;
    }
    return null;
  }

  static String? get voiceBannerId {
    if (Platform.isAndroid) {
      return Android_Banner_VoiceId;
    } else if (Platform.isIOS) {
      return IOS_BANNER_VoiceId;
    }
    return null;
  }

  static String? get settingBannerID {
    if (Platform.isAndroid) {
      return Android_Banner_SETTING_ID;
    } else if (Platform.isIOS) {
      return IOS_BANNER_SETTING_ID;
    }
    return null;
  }

  static String? get faqBannerID {
    if (Platform.isAndroid) {
      return Android_Banner_FAQ_ID;
    } else if (Platform.isIOS) {
      return IOS_BANNER_FAQ_ID;
    }
    return null;
  }

  static String? get chatRewardId {
    if (Platform.isAndroid) {
      return Android_Reward_ID;
    } else if (Platform.isIOS) {
      return IOS_Reward_ID;
    }
    return null;
  }
}
