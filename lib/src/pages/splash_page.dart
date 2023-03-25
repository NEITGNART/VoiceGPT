import 'package:chatgpt/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        // Here we are going to the City List Screen
        // we can make isProduction : true for showing active=true cities
        // we can make isProduction : false for showing active=false cities
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset(
          'assets/splash.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
