import 'package:chatgpt/src/language.dart';
import 'package:chatgpt/src/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: ['a3da23d8efdabc1452a6bffa7b5916dc']),
  // );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // TOdo
  }

  final sp = await SharedPreferences.getInstance();
  Get.create(() => sp);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Chat UI',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      translations: Languages(),
      // locale: Get.deviceLocale,
      // loading from settings
      locale: Get.find<SharedPreferences>().getString('languageCode') == null
          ? Get.deviceLocale
          : Locale(
              Get.find<SharedPreferences>().getString('languageCode') ?? '',
              Get.find<SharedPreferences>().getString('countryCode')),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
