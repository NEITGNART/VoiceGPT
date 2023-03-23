import 'package:chatgpt/src/language.dart';
import 'package:chatgpt/src/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

part 'main.g.dart';

@riverpod
String helloWorld(HelloWorldRef ref) {
  return 'Hello world';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sp = await SharedPreferences.getInstance();
  Get.create(() => sp);

  runApp(const ProviderScope(child: MyApp()));
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
