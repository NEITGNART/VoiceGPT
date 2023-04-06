import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../network/admob_service_helper.dart';
import '../model/language.dart';

class MyLanguage extends StatefulWidget {
  const MyLanguage({super.key});
  @override
  State<MyLanguage> createState() => _MyLanguageState();
}

class _MyLanguageState extends State<MyLanguage> {
  final BannerAd myBanner =
      createBannerAds(AdMobService.languageBannerId ?? '');
  @override
  void initState() {
    super.initState();
    myBanner.load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  List<Language> get languages => [
        Language(
          'Tiếng Việt',
          'assets/vn-flag.svg',
          'vi',
          'VN',
        ),
        Language(
          'English',
          'assets/united-kingdom-flag.svg',
          'en',
          'US',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'language'.tr,
              // align left
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: SvgPicture.asset(
                        languages[index].iconUrl,
                        width: 30,
                        height: 30,
                      ),
                      title: Text(languages[index].name),
                      onTap: () {
                        Get.updateLocale(Locale(languages[index].code,
                            languages[index].countryCode));
                        prefs.setString(
                          'languageCode',
                          languages[index].code,
                        );
                        prefs.setString(
                          'countryCode',
                          languages[index].countryCode,
                        );
                      },
                    );
                  },
                  itemCount: 2),
            ),
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'assets/setting.svg',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: AdWidget(ad: myBanner),
      ),
    );
  }
}
