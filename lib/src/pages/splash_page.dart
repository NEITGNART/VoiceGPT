import 'package:chatgpt/src/pages/chat/repository/template.dart';
import 'package:chatgpt/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'chat/representation/language_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Get.create(() => stt.SpeechToText());
    Get.put(LanguageController());
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () async {
      final box = await Hive.openBox('myBox');
      setState(() {
        bool isFirstTime = box.get('isFirstTime', defaultValue: true);
        if (!isFirstTime) {
          Get.offAll(() => const HomePage());
          // Close the box
          box.close();
          return;
        } else {
          Get.offAll(
            () => IntroductionScreen(
              isTopSafeArea: true,
              pages: [
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
                  title: 'txt_reuse'.tr,
                  body: 'intro_6'.tr,
                  image: Image.asset(
                    "assets/images/intro_6.png",
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
                  title: 'intro_5'.tr,
                  body: 'intro_5_content'.tr,
                  image: Image.asset(
                    "assets/images/intro_5.png",
                  ),
                ),
                PageViewModel(
                  title: 'intro_4'.tr,
                  body: 'intro_4_content'.tr,
                  image: Image.asset(
                    "assets/images/intro_4.png",
                  ),
                ),
              ],
              onDone: () async {
                box.put('isFirstTime', false);
                // Close the box
                box.close();
                Get.offAll(() => const HomePage());
              },
              showSkipButton: true,
              skip: const Text('Skip'),
              next: const Icon(Icons.arrow_forward),
              done: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
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
