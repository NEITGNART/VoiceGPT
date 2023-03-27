import 'dart:io';

import 'package:chatgpt/src/language.dart';
import 'package:chatgpt/src/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

Future<void> launchUrlAsync(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) throw 'Could not launch $url';
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final message = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      await message.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    message.subscribeToTopic('all_users');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 10),
        onTap: (snack) {
          launchUrlAsync(
            Uri.parse(
              '${message.data['url']}}',
            ),
          );
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      launchUrlAsync(
        Uri.parse(
          '${message.data['url']}}',
        ),
      );
    });
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
