import 'package:chatgpt/src/pages/chat/repository/template.dart';
import 'package:chatgpt/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'chat/representation/language_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

final listPagesViewModel = [
  PageViewModel(
    title: 'intro_1'.tr,
    body: 'intro_1_content'.tr,
    image: Image.asset(
      "assets/images/intro_1.png",
    ),
  ),
  PageViewModel(
    title: 'intro_2'.tr,
    body: 'intro_2_content'.tr,
    image: Image.asset(
      "assets/images/intro_2.png",
    ),
  ),
  PageViewModel(
    title: 'intro_3'.tr,
    body: 'intro_3_content'.tr,
    image: Image.asset(
      "assets/images/intro_3.png",
    ),
  ),
  PageViewModel(
    title: 'intro_4'.tr,
    body: 'intro_4_content'.tr,
    image: Image.asset(
      "assets/images/intro_4.png",
      height: 175.0,
    ),
  ),
  PageViewModel(
    title: 'intro_5'.tr,
    body: 'intro_5_content'.tr,
    image: Image.asset(
      "assets/images/intro_5.png",
    ),
  ),
];

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Get.create(() => stt.SpeechToText());
    Get.put(LanguageController());
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        final sp = Get.find<SharedPreferences>();
        final firstTime = sp.getBool('isFirstTime') ?? true;
        if (firstTime == false) {
          Get.offAll(() => const HomePage());
          return;
        } else {
          Get.offAll(() => SafeArea(
                child: IntroductionScreen(
                  pages: listPagesViewModel,
                  onDone: () {
                    // save to local
                    sp.setBool('isFirstTime', false);
                    Get.offAll(() => const HomePage());
                  },
                  showSkipButton: true,
                  skip: const Text('Skip'),
                  next: const Icon(Icons.arrow_forward),
                  done: const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TemplateController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/splash.png')),
    );
  }
}
