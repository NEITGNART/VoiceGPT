import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  late SharedPreferences _prefs;

  AdManager() {
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  int getTimeDifference(int timestamp1, int timestamp2) {
    return max(0, timestamp1 - timestamp2);
  }

  void incrementAdImpressionCount() {
    int impressionCount = _prefs.getInt('rewarded_ad_impression_count') ?? 0;
    int currentTimestamp = getCurrentTimestamp();
    _prefs.setInt('rewarded_ad_impression_count', impressionCount + 1);
    _prefs.setInt('rewarded_ad_impression_timestamp', currentTimestamp);
  }

  Future<bool> canShowRewardedAd(int maxImpressionCount) async {
    int impressionCount = _prefs.getInt('rewarded_ad_impression_count') ?? 0;
    int impressionTimestamp =
        _prefs.getInt('rewarded_ad_impression_timestamp') ?? 0;
    int currentTimestamp = getCurrentTimestamp();
    int maxImpressionCount = 2; // Define your frequency capping limit here
    int maxTimeDifference = 4 *
        60 *
        60; // Define your time period in seconds here (4 hours = 4 * 60 * 60 seconds)
    return impressionCount < maxImpressionCount &&
        getTimeDifference(currentTimestamp, impressionTimestamp) >
            maxTimeDifference;
  }

  void resetAdImpressionCount() {
    _prefs.remove('rewarded_ad_impression_count');
    _prefs.remove('rewarded_ad_impression_timestamp');
  }
}
